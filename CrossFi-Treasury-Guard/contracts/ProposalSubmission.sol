// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ProposalRegistryBase.sol";
import "./interfaces/IProposalRegistry.sol";

abstract contract ProposalSubmission is ProposalRegistryBase {
    function submitProposal(IProposalRegistry.ProposalInput memory input)
        external
        payable
        virtual
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        return _submitProposal(input);
    }

    function _submitProposal(IProposalRegistry.ProposalInput memory input)
        internal
        returns (uint256)
    {
        uint256 proposalId = _validateAndCreateId(
            input.title,
            input.requestedAmount,
            input.votingPeriod,
            input.milestoneDescriptions.length,
            input.milestoneAmounts.length
        );

        _setBasicProposalInfo(proposalId, input.title, input.summary, input.ipfsCID);
        _setAdditionalProposalInfo(proposalId, input.requestedAmount, input.votingPeriod);
        _addMilestones(proposalId, input.milestoneDescriptions, input.milestoneAmounts);

        emit ProposalSubmitted(proposalId, msg.sender, input.title, input.requestedAmount, input.ipfsCID, block.timestamp);
        return proposalId;
    }
}


