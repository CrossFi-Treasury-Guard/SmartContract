// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ProposalVoting.sol";
import "./interfaces/IProposalRegistry.sol";

contract ProposalRegistry is IProposalRegistry, ProposalVoting {
    constructor(address _aiScoreRegistry, address _treasuryEscrow)
        ProposalRegistryBase(_aiScoreRegistry, _treasuryEscrow) {}

    function submitProposal(IProposalRegistry.ProposalInput memory input)
        external
        payable
        override(IProposalRegistry, ProposalSubmission)
        returns (uint256)
    {
        require(msg.value >= 0.001 * 10**18, "Insufficient proposal fee"); // 0.001 XFI
        return _submitProposal(input);
    }

    function castVote(uint256 proposalId, VoteType voteType)
        external
        override(IProposalRegistry, ProposalVoting)
    {
        _castVote(proposalId, voteType);
    }

    function executeProposal(uint256 proposalId)
        external
        override(IProposalRegistry, ProposalVoting)
    {
        _executeProposal(proposalId);
    }

    function getCurrentProposalId()
        external
        view
        override(IProposalRegistry, ProposalRegistryBase)
        returns (uint256)
    {
        return _currentProposalId;
    }

    function getVotingPower(address account)
        external
        view
        override(IProposalRegistry, ProposalRegistryBase)
        returns (uint256)
    {
        return account.balance;
    }

    function getProposal(uint256 proposalId) external view override returns (
        uint256 id,
        address proposer,
        string memory title,
        string memory summary,
        uint256 requestedAmount,
        ProposalStatus status,
        uint256 aiScore,
        uint256 votingStart,
        uint256 votingEnd,
        uint256 forVotes,
        uint256 againstVotes,
        uint256 abstainVotes
    ) {
        require(proposalId > 0 && proposalId <= _currentProposalId, "Invalid proposal ID");

        Proposal storage p = proposals[proposalId];

        return (
            p.id,
            p.proposer,
            p.title,
            p.summary,
            p.requestedAmount,
            p.status,
            p.aiScore,
            p.votingStart,
            p.votingEnd,
            p.forVotes,
            p.againstVotes,
            p.abstainVotes
        );
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}


















