// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

interface IProposalRegistry {
    enum ProposalStatus {
        PendingAIReview,
        Voting,
        Approved,
        RejectedByAI,
        RejectedByDAO,
        Executed,
        Cancelled
    }

    enum VoteType {
        Against,
        For,
        Abstain
    }

    struct Milestone {
        string description;
        uint256 amount;
        bool completed;
        uint256 completionTime;
    }

    struct Proposal {
        uint256 id;
        address proposer;
        string title;
        string summary;
        string ipfsCID;
        uint256 requestedAmount;
        ProposalStatus status;
        uint256 submissionTime;
        uint256 votingPeriod;
        uint256 votingStart;
        uint256 votingEnd;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        uint256 aiScore;
        string aiJustification;
        Milestone[] milestones;
        uint256 totalSupplyAtStart;
    }

    struct ProposalInput {
        string title;
        string summary;
        string ipfsCID;
        uint256 requestedAmount;
        string[] milestoneDescriptions;
        uint256[] milestoneAmounts;
        uint256 votingPeriod;
    }

    function submitProposal(ProposalInput memory input) external payable returns (uint256);

    function castVote(uint256 proposalId, VoteType voteType) external;
    function executeProposal(uint256 proposalId) external;

    function getProposal(uint256 proposalId) external view returns (
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
    );

    function getCurrentProposalId() external view returns (uint256);
    function getVotingPower(address account) external view returns (uint256);
}
