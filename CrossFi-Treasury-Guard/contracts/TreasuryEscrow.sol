// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/ITreasuryEscrow.sol";
import "./utils/ExtendedAccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TreasuryEscrow
 * @dev Handles milestone-based fund release for approved proposals
 * @author CrossFi Treasury Guard Team
 */

contract TreasuryEscrow is ITreasuryEscrow, ExtendedAccessControl, ReentrancyGuard, Pausable {
    
    // data structure
    struct EscrowData {
        uint256 proposalId;
        address beneficiary;
        uint256 totalAmount;
        uint256 releasedAmount;
        uint256 milestoneCount;
        mapping(uint256 => MilestoneData) milestones;
        EscrowStatus status;
        uint256 creationTime;
        uint256 lastReleaseTime;
        bool exists;
    }
    
    struct MilestoneData {
        uint256 amount;
        string description;
        bool completed;
        uint256 completionTime;
        string evidenceIPFS;
        address approver;
        bool disputed;
        string disputeReason;
    }

    mapping(uint256 => EscrowData) private escrows;
    mapping(address => uint256[]) private beneficiaryEscrows;
    mapping(address => bool) public milestoneApprovers;
    
    uint256 public totalEscrowedAmount;
    uint256 public totalReleasedAmount;
    uint256 public activeEscrowCount;

    // configuration
    uint256 public constant MILESTONE_APPROVAL_PERIOD = 7 days;
    uint256 public constant DISPUTE_RESOLUTION_PERIOD = 14 days;
    uint256 public constant MAX_MILESTONES = 10;
    uint256 public constant PROPOSAL_FEE = 0.001 * 10**18; // 0.001 XFI in wei
    
    event MilestoneCompleted(
        uint256 indexed proposalId,
        uint256 indexed milestoneIndex,
        uint256 amount,
        string evidenceIPFS,
        address approver
    );

    event MilestoneDisputed(
        uint256 indexed proposalId,
        uint256 indexed milestoneIndex,
        string reason,
        address disputer
    );
    
    event DisputeResolved(
        uint256 indexed proposalId,
        uint256 indexed milestoneIndex,
        bool approved,
        address resolver
    );
    
    event EscrowCancelled(
        uint256 indexed proposalId,
        uint256 refundedAmount,
        string reason
    );
    
    event MilestoneApproverUpdated(address indexed approver, bool authorized);

    modifier onlyValidEscrow(uint256 proposalId) {
        require(escrows[proposalId].exists, "Escrow does not exist");
        _;
    }
    
    modifier onlyBeneficiary(uint256 proposalId) {
        require(escrows[proposalId].beneficiary == msg.sender, "Not beneficiary");
        _;
    }
    
    modifier onlyMilestoneApprover() {
        require(milestoneApprovers[msg.sender], "Not authorized approver");
        _;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(TREASURY_MANAGER_ROLE, msg.sender);
        
        // initial milestone approver
        milestoneApprovers[msg.sender] = true;
    }

    /**
     * @dev Create escrow for approved proposal
     * @param proposalId The proposal ID
     * @param beneficiary Address to receive funds
     * @param totalAmount Total amount to be escrowed
     * @param milestoneCount Number of milestones
     */
    function createEscrow(
        uint256 proposalId,
        address beneficiary,
        uint256 totalAmount,
        uint256 milestoneCount
    ) external payable override onlyRole(TREASURY_MANAGER_ROLE) whenNotPaused nonReentrant {
        require(proposalId > 0, "Invalid proposal ID");
        require(beneficiary != address(0), "Invalid beneficiary");
        require(totalAmount > 0, "Amount must be positive");
        require(milestoneCount > 0 && milestoneCount <= MAX_MILESTONES, "Invalid milestone count");
        require(!escrows[proposalId].exists, "Escrow already exists");
        require(msg.value >= totalAmount + PROPOSAL_FEE, "Insufficient XFI sent");

        // Deposit fee to contract
        if (msg.value > totalAmount) {
            totalEscrowedAmount += PROPOSAL_FEE;
        }

        require(address(this).balance >= totalAmount, "Insufficient treasury balance after fee");

        EscrowData storage escrow = escrows[proposalId];
        escrow.proposalId = proposalId;
        escrow.beneficiary = beneficiary;
        escrow.totalAmount = totalAmount;
        escrow.releasedAmount = 0;
        escrow.milestoneCount = milestoneCount;
        escrow.status = EscrowStatus.Active;
        escrow.creationTime = block.timestamp;
        escrow.lastReleaseTime = 0;
        escrow.exists = true;
        
        beneficiaryEscrows[beneficiary].push(proposalId);
        totalEscrowedAmount += totalAmount;
        activeEscrowCount++;
        
        emit EscrowCreated(proposalId, beneficiary, totalAmount, milestoneCount);
    }

    /**
     * @dev Set milestone details for an escrow
     * @param proposalId The proposal ID
     * @param milestoneIndex Index of the milestone
     * @param amount Amount for this milestone
     * @param description Milestone description
     */
    function setMilestone(
        uint256 proposalId,
        uint256 milestoneIndex,
        uint256 amount,
        string memory description
    ) external onlyRole(TREASURY_MANAGER_ROLE) onlyValidEscrow(proposalId) {
        EscrowData storage escrow = escrows[proposalId];
        require(milestoneIndex < escrow.milestoneCount, "Invalid milestone index");
        require(amount > 0, "Amount must be positive");
        require(bytes(description).length > 0, "Description required");
        require(escrow.status == EscrowStatus.Active, "Escrow not active");
        
        MilestoneData storage milestone = escrow.milestones[milestoneIndex];
        require(milestone.amount == 0, "Milestone already set");
        
        milestone.amount = amount;
        milestone.description = description;
        milestone.completed = false;
        milestone.completionTime = 0;
        milestone.disputed = false;
    }

    /**
     * @dev Submit milestone completion evidence
     * @param proposalId The proposal ID
     * @param milestoneIndex Index of the milestone
     * @param evidenceIPFS IPFS CID containing completion evidence
     */
    function submitMilestoneEvidence(
        uint256 proposalId,
        uint256 milestoneIndex,
        string memory evidenceIPFS
    ) external onlyValidEscrow(proposalId) onlyBeneficiary(proposalId) whenNotPaused {
        EscrowData storage escrow = escrows[proposalId];
        require(milestoneIndex < escrow.milestoneCount, "Invalid milestone index");
        require(escrow.status == EscrowStatus.Active, "Escrow not active");
        require(bytes(evidenceIPFS).length > 0, "Evidence IPFS required");
        
        MilestoneData storage milestone = escrow.milestones[milestoneIndex];
        require(milestone.amount > 0, "Milestone not set");
        require(!milestone.completed, "Milestone already completed");
        require(!milestone.disputed, "Milestone disputed");
        
        milestone.evidenceIPFS = evidenceIPFS;
        
        emit MilestoneCompleted(proposalId, milestoneIndex, milestone.amount, evidenceIPFS, address(0));
    }

    /**
     * @dev Approve milestone and release funds
     * @param proposalId The proposal ID
     * @param milestoneIndex Index of the milestone
     */
    function approveMilestone(
        uint256 proposalId,
        uint256 milestoneIndex
    ) external onlyMilestoneApprover onlyValidEscrow(proposalId) whenNotPaused nonReentrant {
        EscrowData storage escrow = escrows[proposalId];
        require(milestoneIndex < escrow.milestoneCount, "Invalid milestone index");
        require(escrow.status == EscrowStatus.Active, "Escrow not active");
        
        MilestoneData storage milestone = escrow.milestones[milestoneIndex];
        require(milestone.amount > 0, "Milestone not set");
        require(!milestone.completed, "Milestone already completed");
        require(!milestone.disputed, "Milestone disputed");
        require(bytes(milestone.evidenceIPFS).length > 0, "No evidence submitted");
        require(address(this).balance >= milestone.amount, "Insufficient funds");

        if (milestoneIndex > 0) {
            require(escrow.milestones[milestoneIndex - 1].completed, "Previous milestone not completed");
        }
        
        milestone.completed = true;
        milestone.completionTime = block.timestamp;
        milestone.approver = msg.sender;
        
        // Releasing of funds
        escrow.releasedAmount += milestone.amount;
        escrow.lastReleaseTime = block.timestamp;
        totalReleasedAmount += milestone.amount;

        (bool sent, ) = escrow.beneficiary.call{value: milestone.amount}("");
        require(sent, "Failed to send XFI");

        // This checks if all the milestones are completed
        bool allCompleted = true;
        for (uint256 i = 0; i < escrow.milestoneCount; i++) {
            if (!escrow.milestones[i].completed) {
                allCompleted = false;
                break;
            }
        }
        
        if (allCompleted) {
            escrow.status = EscrowStatus.Completed;
            activeEscrowCount--;
        }
        
        emit FundsReleased(proposalId, milestoneIndex, milestone.amount, escrow.beneficiary);
    }

    /**
     * @dev Dispute a milestone
     * @param proposalId The proposal ID
     * @param milestoneIndex Index of the milestone
     * @param reason Reason for dispute
     */
    function disputeMilestone(
        uint256 proposalId,
        uint256 milestoneIndex,
        string memory reason
    ) external onlyMilestoneApprover onlyValidEscrow(proposalId) {
        EscrowData storage escrow = escrows[proposalId];
        require(milestoneIndex < escrow.milestoneCount, "Invalid milestone index");
        require(escrow.status == EscrowStatus.Active, "Escrow not active");
        require(bytes(reason).length > 0, "Dispute reason required");
        
        MilestoneData storage milestone = escrow.milestones[milestoneIndex];
        require(milestone.amount > 0, "Milestone not set");
        require(!milestone.completed, "Milestone already completed");
        require(!milestone.disputed, "Milestone already disputed");
        
        milestone.disputed = true;
        milestone.disputeReason = reason;
        
        emit MilestoneDisputed(proposalId, milestoneIndex, reason, msg.sender);
    }

    /**
     * @dev Resolve milestone dispute
     * @param proposalId The proposal ID
     * @param milestoneIndex Index of the milestone
     * @param approved Whether to approve the milestone
     */
    function resolveDispute(
        uint256 proposalId,
        uint256 milestoneIndex,
        bool approved
    ) external onlyRole(ADMIN_ROLE) onlyValidEscrow(proposalId) nonReentrant {
        EscrowData storage escrow = escrows[proposalId];
        require(milestoneIndex < escrow.milestoneCount, "Invalid milestone index");
        
        MilestoneData storage milestone = escrow.milestones[milestoneIndex];
        require(milestone.disputed, "Milestone not disputed");
        
        milestone.disputed = false;
        
        if (approved) {
            milestone.completed = true;
            milestone.completionTime = block.timestamp;
            milestone.approver = msg.sender;
            
            escrow.releasedAmount += milestone.amount;
            escrow.lastReleaseTime = block.timestamp;
            totalReleasedAmount += milestone.amount;

            require(address(this).balance >= milestone.amount, "Insufficient funds");
            (bool sent, ) = escrow.beneficiary.call{value: milestone.amount}("");
            require(sent, "Failed to send XFI");
            
            emit FundsReleased(proposalId, milestoneIndex, milestone.amount, escrow.beneficiary);
        }
        
        emit DisputeResolved(proposalId, milestoneIndex, approved, msg.sender);
    }

    /**
     * @dev Cancel escrow and refund remaining funds
     * @param proposalId The proposal ID
     * @param reason Reason for cancellation
     */
    function cancelEscrow(
        uint256 proposalId,
        string memory reason
    ) external onlyRole(ADMIN_ROLE) onlyValidEscrow(proposalId) nonReentrant {
        EscrowData storage escrow = escrows[proposalId];
        require(escrow.status == EscrowStatus.Active, "Escrow not active");
        require(bytes(reason).length > 0, "Cancellation reason required");
        
        uint256 refundAmount = escrow.totalAmount - escrow.releasedAmount;
        
        escrow.status = EscrowStatus.Cancelled;
        activeEscrowCount--;
        
        if (refundAmount > 0) {
            require(address(this).balance >= refundAmount, "Insufficient funds");
            (bool sent, ) = msg.sender.call{value: refundAmount}("");
            require(sent, "Failed to refund");
            totalEscrowedAmount -= refundAmount;
        }
        
        emit EscrowCancelled(proposalId, refundAmount, reason);
    }

    /**
     * @dev Get escrow details
     * @param proposalId The proposal ID
     */
    function getEscrow(uint256 proposalId) external view override onlyValidEscrow(proposalId) returns (
        address beneficiary,
        uint256 totalAmount,
        uint256 releasedAmount,
        uint256 milestoneCount,
        EscrowStatus status,
        uint256 creationTime
    ) {
        EscrowData storage escrow = escrows[proposalId];
        return (
            escrow.beneficiary,
            escrow.totalAmount,
            escrow.releasedAmount,
            escrow.milestoneCount,
            escrow.status,
            escrow.creationTime
        );
    }

    /**
     * @dev Get milestone details
     * @param proposalId The proposal ID
     * @param milestoneIndex Index of the milestone
     */
    function getMilestone(uint256 proposalId, uint256 milestoneIndex) external view onlyValidEscrow(proposalId) returns (
        uint256 amount,
        string memory description,
        bool completed,
        uint256 completionTime,
        string memory evidenceIPFS,
        address approver,
        bool disputed,
        string memory disputeReason
    ) {
        require(milestoneIndex < escrows[proposalId].milestoneCount, "Invalid milestone index");
        
        MilestoneData storage milestone = escrows[proposalId].milestones[milestoneIndex];
        return (
            milestone.amount,
            milestone.description,
            milestone.completed,
            milestone.completionTime,
            milestone.evidenceIPFS,
            milestone.approver,
            milestone.disputed,
            milestone.disputeReason
        );
    }

    /**
     * @dev Get beneficiary's escrows
     * @param beneficiary Beneficiary address
     */
    function getBeneficiaryEscrows(address beneficiary) external view returns (uint256[] memory) {
        return beneficiaryEscrows[beneficiary];
    }

    /**
     * @dev Check if escrow exists
     * @param proposalId The proposal ID
     */
    function escrowExists(uint256 proposalId) external view override returns (bool) {
        return escrows[proposalId].exists;
    }

    /**
     * @dev Get treasury statistics
     */
    function getTreasuryStats() external view returns (
        uint256 _totalEscrowedAmount,
        uint256 _totalReleasedAmount,
        uint256 _activeEscrowCount,
        uint256 _availableBalance
    ) {
        return (
            totalEscrowedAmount,
            totalReleasedAmount,
            activeEscrowCount,
            address(this).balance
        );
    }

    /**
     * @dev Set milestone approver authorization
     * @param approver Approver address
     * @param authorized Authorization status
     */
    function setMilestoneApprover(address approver, bool authorized) external onlyRole(ADMIN_ROLE) {
        require(approver != address(0), "Invalid approver address");
        milestoneApprovers[approver] = authorized;
        emit MilestoneApproverUpdated(approver, authorized);
    }

    /**
     * @dev Emergency withdraw function
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(amount <= address(this).balance, "Insufficient balance");
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send XFI");
    }

    /**
     * @dev Deposit funds to treasury
     */
    function depositFunds() external payable onlyRole(TREASURY_MANAGER_ROLE) {
        require(msg.value > 0, "Amount must be positive");
        totalEscrowedAmount += msg.value; // Update tracking
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}