📘 Smart Contract Documentation
This document provides a detailed overview of each smart contract used in the project and how they interact. These contracts are built to support decentralized proposal governance, scoring, reputation management, and role-based access control.

🔐 ExtendedAccessControl
Contract Address: 0xbe8f9e81a0af91196e4567dc4c2f5958a6262788
Purpose: This contract manages roles and permissions across the protocol.

Key Roles:

DEFAULT_ADMIN_ROLE: Full administrative rights.

DAO_ROLE: Used by the core DAO to perform privileged actions.

SCORER_ROLE: Allows score submission by trusted DAO members.

DISPUTE_HANDLER_ROLE: Handles dispute management and resolution.

Functions:

Grant or revoke roles to accounts.

Verify if an address holds a particular role.

📋 ProposalRegistry
Purpose: Manages proposals submitted by contributors, including milestones and progress tracking.

Core Features:

Users can submit detailed proposals.

Each proposal includes milestones and requested rewards.

DAO members can score proposals via the ScoreOracle.

Main Functions:

submitProposal(...): Submit a new proposal with metadata.

updateMilestoneStatus(...): Update the completion status of milestones.

getProposal(...): Fetch data of a submitted proposal.

getMilestones(...): Retrieve milestones for a proposal.

Events:

ProposalSubmitted

MilestoneUpdated

🧠 ScoreOracle
Purpose: Collects and aggregates DAO scores on proposals or user contributions.

Features:

DAO members with the right role can submit scores.

Scores are aggregated to determine approval or reward.

Prevents resubmission after finalization.

Main Functions:

submitScore(...): Submit a score for a proposal or user.

getAverageScore(...): Calculate the average of all submitted scores.

resetScore(...): Clear scores when needed.

Security:

Only addresses with SCORER_ROLE can submit scores.

Scores can be challenged through the dispute system.

⚖️ DisputeModule
Purpose: Allows users to raise disputes on unfair or suspicious scores.

Features:

Users can dispute scores within a defined time window (e.g., 48 hours).

Disputes must include a reason and can be resolved by an arbitrator or admin.

Transparent dispute history per score or proposal.

Main Functions:

raiseDispute(...): Submit a challenge to a specific score.

resolveDispute(...): Admin resolves dispute after review.

getDisputes(...): View all disputes related to a score.

Events:

DisputeRaised

DisputeResolved

🧬 ReputationNFT
Purpose: Mints non-transferable (soulbound) NFTs based on verified contribution or proposal scores.

Features:

Users earn NFTs based on score tiers (e.g., Bronze, Silver, Gold).

NFTs are proof of reputation and contribution.

Tiers are calculated based on aggregate scores or milestones completed.

Main Functions:

mint(...): Mint an NFT for an eligible user.

getTier(...): Check which level/tier a user belongs to.

getNFTMetadata(...): View details about a minted NFT.

🔗 Contract Interactions Overview
The system is modular. Below is a simple interaction flow:

The AccessControl contract defines permissions.

The ProposalRegistry stores all proposals and milestones.

The ScoreOracle allows DAO members to score proposals.

The DisputeModule allows disputes to be raised if scores are unfair.

The ReputationNFT contract mints reputation badges for contributors who meet performance or score thresholds.

🛡️ Security Notes
All sensitive operations are protected by roles using ExtendedAccessControl.

Dispute resolution prevents manipulation or scoring fraud.

Scores and decisions are immutable once finalized.

Reputation NFTs are non-transferable and bound to user identity (wallet).
