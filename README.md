##n🛡️ CrossFi Treasury Guard – AI Score Registry
A secure, modular, and decentralized smart contract system designed to register and verify AI-generated scores for governance proposals within the CrossFi DAO ecosystem.

This system empowers the treasury with verifiable AI-based evaluation, IPFS-backed justification, and fine-grained role-based access control — delivering an intelligent, transparent, and scalable infrastructure for proposal governance.

## 🚀 Key Features
## 🔍 AI-Powered Scoring
Submit AI-generated evaluations tied to individual proposals, covering dimensions such as feasibility, impact, and utility. Each score is backed by verifiable justifications stored on IPFS.

## 🔐 Role-Based Access Control
Access is strictly managed using smart contract roles (Admin, Oracle, etc.), powered by OpenZeppelin’s AccessControl standard with custom extensions for modularity.

## ⏸ Pausable Registry
Contracts can be paused by Admins in emergency scenarios, ensuring operational control and minimizing risk during upgrades or security audits.

## 📁 Immutable Storage via IPFS
AI justifications and metadata are stored off-chain using IPFS, ensuring decentralized traceability and tamper-proof documentation.

## 🛠 Dispute Resolution Ready
Architecture supports future upgrades for proposal challenge periods, on-chain appeals, or AI-model dispute protocols.

## 🎯 Purpose and Hackathon Alignment
This project aligns with CrossFi’s vision to modernize decentralized treasury management through AI-integrated systems. It supports:

DAO proposal scoring using verifiable AI models

Transparent justification storage via IPFS

Secure, upgradeable contract architecture

Plug-and-play compatibility with CrossFi governance tooling

## 🧩 Project Structure
CrossFi-Treasury-Guard/
│
├── abis/                         # ABI files for frontend or testing integration
│   ├── AIScoreRegistry.abi.json
│   ├── ExtendedAccessControl.abi.json
│   ├── ProposalRegistry.abi.json
│   └── TreasuryEscrow.abi.json
│
├── contracts/                    # Core Solidity smart contracts
│   ├── interfaces/              # Reusable interfaces
│   │   ├── IAIScoreRegistry.sol
│   │   ├── IProposalRegistry.sol
│   │   └── ITreasuryEscrow.sol
│   │
│   ├── utils/                   # Shared logic & access control
│   │   └── ExtendedAccessControl.sol
│   │
│   ├── AIScoreRegistry.sol      # AI score submission and retrieval
│   ├── ProposalRegistry.sol     # Proposal state and validation
│   ├── ProposalRegistryBase.sol
│   ├── ProposalSubmission.sol   # Handles new proposals
│   ├── ProposalVoting.sol       # Voting logic (DAO-compatible)
│   └── TreasuryEscrow.sol       # Treasury release logic and milestones
│
├── docs/                         # Additional documentation
│   └── ContractDocumentation.md
│
├── README.md                     # This project overview
└── compiler_config.json          # Solidity compiler settings (v0.8.20)
## 🧪 Testing in Remix IDE
Automated tests will be added in the future. For now, manual validation via Remix is recommended.

## ✅ Steps to Test:
Open Remix
➤ https://remix.ethereum.org

## Setup Project Structure
➤ Create and paste code into files based on the structure under contracts/.

Compiler Settings

Compiler version: 0.8.20

Optimization: Enabled, Runs: 200

Deploy Contracts

Start with AIScoreRegistry.sol

Use either JavaScript VM for local or CrossFi Testnet

Copy deployed addresses for later interaction

## 🔧 Interact with Functions:
Function	Description
submitAIScore(proposalId, overallScore, justificationIPFS, modelVersion, breakdown)	Authorized Oracle submits an AI score with justification
getAIScore(proposalId)	Returns full score details for a proposal
setOracleAuthorization(address, bool)	Admin grants/revokes oracle role
pause() / unpause()	Admin toggles contract activity

## 🔎 Validation: Use Remix logs to confirm events like AIScoreSubmitted, and inspect the contract state using the debugger.

🔧 Compiler Configuration
For advanced users or integration with tools like Hardhat or Foundry, use the following compiler settings:

json
Copy
Edit
{
  "language": "Solidity",
  "sources": {
    "AIScoreRegistry.sol": {
      "content": "<paste-contract-content>"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "evmVersion": "paris",
    "outputSelection": {
      "*": {
        "*": ["abi", "evm.bytecode", "evm.deployedBytecode"]
      }
    }
  }
}
## Note: I also encountered this error =>  Stack Too Deep
Three words of horror, which made me panicked while using Remix so check this link to check the steps to address this issues while coding, testing e.t.c ➤ 

## 📌 Usage Without Verification
The contract works without verification on explorers like the CrossFi Testnet Explorer. Verification is only required for transparency and audits. Functionality remains unaffected if:

The bytecode matches the compiled output

Required dependencies (e.g., OpenZeppelin) are correctly imported or flattened

## 🛡️ Future Enhancements
These features are designed for future integration and may be built into follow-up versions:

Score Dispute Mechanism: DAO members can challenge AI scores within a fixed timeframe.

On-Chain AI Versioning: Enable transparent tracking of model versions used for each score.

Cross-Chain Support: Deploy to Ethereum, CrossFi Testnet, and other EVM-compatible chains.

Governance Integration: Use scores to weight DAO votes or filter out weak proposals.

## 🧠 Learn More
Explore how the AI Score Registry fits into the broader CrossFi Treasury Guard initiative by pairing it with the frontend interface, milestone escrow logic, and DAO dashboard systems.

📖 See companion frontend: CrossFi Treasury Guard – AI-Governed DAO (Frontend)

## 📝 License
This project is released under the MIT License. See the LICENSE file for details.

## 🧑‍💻 Contribution & Support
Open to feedback, suggestions, and contributions:

Submit issues or feature requests on GitHub

Fork the repo and submit PRs

