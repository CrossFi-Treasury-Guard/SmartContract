// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IProposalRegistry.sol";
import "./interfaces/IAIScoreRegistry.sol";
import "./interfaces/ITreasuryEscrow.sol";
import "./utils/ExtendedAccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

abstract contract ProposalRegistryBase is ExtendedAccessControl, ReentrancyGuard, Pausable {
    IAIScoreRegistry public aiScoreRegistry;
    ITreasuryEscrow public treasuryEscrow;
    
    uint256 internal _currentProposalId;
    
    // Constants
    uint256 public constant MIN_VOTING_PERIOD = 3 days;
    uint256 public constant MAX_VOTING_PERIOD = 14 days;
    uint256 public constant MIN_PROPOSAL_THRESHOLD = 1000 * 10**18; // Native XFI in wei
    uint256 public constant QUORUM_PERCENTAGE = 15;
    uint256 public constant APPROVAL_THRESHOLD = 51;
    uint256 public constant AI_SCORE_THRESHOLD = 70;
    uint256 public constant MAX_MILESTONES = 10;
    uint256 public constant MAX_REQUESTED_AMOUNT = 1000000 * 10**18; // 1M XFI in wei
    
    // Mappings
    mapping(uint256 => IProposalRegistry.Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => mapping(address => IProposalRegistry.VoteType)) public voterChoices;
    mapping(address => uint256) public proposerReputation;
    
    // Events
    event ProposalSubmitted(uint256 indexed proposalId, address indexed proposer, string title, uint256 requestedAmount, string ipfsCID, uint256 timestamp);
    event VotingStarted(uint256 indexed proposalId, uint256 votingStart, uint256 votingEnd);
    event VoteCast(uint256 indexed proposalId, address indexed voter, IProposalRegistry.VoteType voteType, uint256 weight);
    event ProposalApproved(uint256 indexed proposalId, uint256 amount);
    event ProposalRejected(uint256 indexed proposalId, string reason);
    event ProposalExecuted(uint256 indexed proposalId, IProposalRegistry.ProposalStatus status);
    event ProposalCancelled(uint256 indexed proposalId, address indexed proposer, uint256 timestamp);
    event AIScoreProcessed(uint256 indexed proposalId, uint256 score, string justification);
    event AIScoreRegistryUpdated(address newRegistry);
    event TreasuryEscrowUpdated(address newEscrow);

    constructor(address _aiScoreRegistry, address _treasuryEscrow) {
        require(_aiScoreRegistry != address(0), "Invalid AI registry");
        require(_treasuryEscrow != address(0), "Invalid treasury escrow");
        
        aiScoreRegistry = IAIScoreRegistry(_aiScoreRegistry);
        treasuryEscrow = ITreasuryEscrow(_treasuryEscrow);
        _currentProposalId = 0;
        
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }
    
    /**
     * @dev Validate input and create new proposal ID
     */
    function _validateAndCreateId(
        string memory title,
        uint256 requestedAmount,
        uint256 votingPeriod,
        uint256 milestonesLength,
        uint256 milestoneAmountsLength
    ) internal returns (uint256) {
        // Input validation
        require(bytes(title).length > 0 && bytes(title).length <= 200, "Invalid title length");
        require(requestedAmount > 0 && requestedAmount <= MAX_REQUESTED_AMOUNT, "Invalid amount");
        require(votingPeriod >= MIN_VOTING_PERIOD && votingPeriod <= MAX_VOTING_PERIOD, "Invalid voting period");
        require(milestonesLength == milestoneAmountsLength, "Milestone arrays mismatch");
        require(milestonesLength > 0 && milestonesLength <= MAX_MILESTONES, "Invalid milestone count");
        
        // Check proposer eligibility (using native balance)
        require(msg.sender.balance >= MIN_PROPOSAL_THRESHOLD, "Insufficient XFI balance");
        
        // Create new proposal ID
        return _incrementProposalId();
    }
    
    /**
     * @dev Set basic proposal information
     */
    function _setBasicProposalInfo(
        uint256 proposalId,
        string memory title,
        string memory summary,
        string memory ipfsCID
    ) internal {
        require(bytes(summary).length > 0 && bytes(summary).length <= 1000, "Invalid summary length");
        require(bytes(ipfsCID).length > 0, "IPFS CID required");
        
        IProposalRegistry.Proposal storage proposal = proposals[proposalId];
        proposal.id = proposalId;
        proposal.proposer = msg.sender;
        proposal.title = title;
        proposal.summary = summary;
        proposal.ipfsCID = ipfsCID;
        proposal.status = IProposalRegistry.ProposalStatus.PendingAIReview;
        proposal.submissionTime = block.timestamp;
    }
    
    /**
     * @dev Set additional proposal information
     */
    function _setAdditionalProposalInfo(
        uint256 proposalId,
        uint256 requestedAmount,
        uint256 votingPeriod
    ) internal {
        IProposalRegistry.Proposal storage proposal = proposals[proposalId];
        proposal.requestedAmount = requestedAmount;
        proposal.votingPeriod = votingPeriod;
        proposal.totalSupplyAtStart = 0; 
    }
    
    /**
     * @dev Add milestones to proposal
     */
    function _addMilestones(
        uint256 proposalId,
        string[] memory descriptions,
        uint256[] memory amounts
    ) internal {
        // Validate milestone amounts sum to requested amount
        uint256 totalMilestoneAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "Milestone amount must be positive");
            require(bytes(descriptions[i]).length > 0, "Milestone description required");
            totalMilestoneAmount += amounts[i];
        }
        
        IProposalRegistry.Proposal storage proposal = proposals[proposalId];
        require(totalMilestoneAmount == proposal.requestedAmount, "Milestone amounts don't sum to requested amount");
        
        // Add milestones
        for (uint256 i = 0; i < descriptions.length; i++) {
            proposal.milestones.push(IProposalRegistry.Milestone({
                description: descriptions[i],
                amount: amounts[i],
                completed: false,
                completionTime: 0
            }));
        }
    }

    function getCurrentProposalId() external view virtual returns (uint256) {
        return _currentProposalId;
    }

    function getVotingPower(address account) external view virtual returns (uint256) {
        return account.balance; // Native XFI balance
    }

    function _incrementProposalId() internal returns (uint256) {
        _currentProposalId++;
        return _currentProposalId;
    }
    
    // Modifiers
    modifier onlyValidProposal(uint256 proposalId) {
        require(proposalId > 0 && proposalId <= _currentProposalId, "Invalid proposal ID");
        _;
    }
    
    modifier onlyProposer(uint256 proposalId) {
        require(proposals[proposalId].proposer == msg.sender, "Not the proposer");
        _;
    }
    
    modifier onlyDuringVoting(uint256 proposalId) {
        IProposalRegistry.Proposal storage proposal = proposals[proposalId];
        require(proposal.status == IProposalRegistry.ProposalStatus.Voting, "Not in voting phase");
        require(block.timestamp >= proposal.votingStart && block.timestamp <= proposal.votingEnd, "Voting period invalid");
        _;
    }
    
    function updateAIScoreRegistry(address newRegistry) external onlyRole(ADMIN_ROLE) {
        require(newRegistry != address(0), "Invalid address");
        aiScoreRegistry = IAIScoreRegistry(newRegistry);
        emit AIScoreRegistryUpdated(newRegistry);
    }

    function updateTreasuryEscrow(address newEscrow) external onlyRole(ADMIN_ROLE) {
        require(newEscrow != address(0), "Invalid address");
        treasuryEscrow = ITreasuryEscrow(newEscrow);
        emit TreasuryEscrowUpdated(newEscrow);
    }
}






