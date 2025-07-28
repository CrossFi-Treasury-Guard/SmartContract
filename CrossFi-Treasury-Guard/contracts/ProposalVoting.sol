// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ProposalSubmission.sol";

abstract contract ProposalVoting is ProposalSubmission {
    
    function castVote(uint256 proposalId, IProposalRegistry.VoteType voteType) external virtual whenNotPaused {
        _castVote(proposalId, voteType);
    }

    function executeProposal(uint256 proposalId) external virtual nonReentrant {
        _executeProposal(proposalId);
    }

    function _castVote(uint256 proposalId, IProposalRegistry.VoteType voteType) internal {
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        
        IProposalRegistry.Proposal storage proposal = proposals[proposalId];
        require(proposal.status == IProposalRegistry.ProposalStatus.Voting, "Not voting");
        
        uint256 votingPower = msg.sender.balance; 
        hasVoted[proposalId][msg.sender] = true;
        
        // Update vote counts
        _updateVoteCounts(proposal, voteType, votingPower);
        
        emit VoteCast(proposalId, msg.sender, voteType, votingPower);
    }

    function _updateVoteCounts(
        IProposalRegistry.Proposal storage proposal,
        IProposalRegistry.VoteType voteType,
        uint256 votingPower
    ) internal {
        if (voteType == IProposalRegistry.VoteType.For) {
            proposal.forVotes += votingPower;
        } else if (voteType == IProposalRegistry.VoteType.Against) {
            proposal.againstVotes += votingPower;
        } else {
            proposal.abstainVotes += votingPower;
        }
    }

    function _executeProposal(uint256 proposalId) internal {
        IProposalRegistry.Proposal storage proposal = proposals[proposalId];
        require(proposal.status == IProposalRegistry.ProposalStatus.Voting, "Not voting");
        require(block.timestamp > proposal.votingEnd, "Voting active");
        
        // Calculate voting results
        (bool hasQuorum, bool approved) = _calculateVotingResults(proposal);
        
        // Update proposal status and handle results
        _handleVotingResults(proposalId, proposal, hasQuorum, approved);
        
        emit ProposalExecuted(proposalId, proposal.status);
    }

    function _calculateVotingResults(IProposalRegistry.Proposal storage proposal) 
        internal 
        view 
        returns (bool hasQuorum, bool approved) 
    {
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;
        hasQuorum = totalVotes >= 1000 * 10**18;
        approved = hasQuorum && proposal.forVotes > proposal.againstVotes;
    }

    function _handleVotingResults(
        uint256 proposalId,
        IProposalRegistry.Proposal storage proposal,
        bool hasQuorum,
        bool approved
    ) internal {
        if (approved) {
            proposal.status = IProposalRegistry.ProposalStatus.Approved;
            treasuryEscrow.createEscrow(proposalId, proposal.proposer, proposal.requestedAmount, proposal.milestones.length);
            emit ProposalApproved(proposalId, proposal.requestedAmount);
        } else {
            proposal.status = IProposalRegistry.ProposalStatus.RejectedByDAO;
            emit ProposalRejected(proposalId, hasQuorum ? "Majority voted against" : "Insufficient quorum");
        }
    }
}


