## CrossFi Treasury Guard – AI Score Registry
## 🧠 Overview
CrossFi Treasury Guard – AI Score Registry is a decentralized smart contract system purpose-built for evaluating governance proposals through AI-generated scores. Developed for the CrossFi Hackathon, the registry enhances transparency, security, and operational efficiency in treasury governance by combining AI-driven assessments with on-chain role-based access control.

All scores and their justifications are securely stored on IPFS, ensuring that proposal evaluations remain immutable, verifiable, and transparent. The contracts are fully modular and upgrade-ready, allowing for seamless integration with broader treasury workflows within the CrossFi ecosystem.

## 🎯 Project Goals
## 🔗 Hackathon Alignment
This project aligns closely with CrossFi’s mission to innovate the decentralized finance (DeFi) space. By integrating AI into on-chain decision-making, the AI Score Registry supports smarter governance, improves proposal quality, and increases trust in DAO operations.

## 🔐 Core Functionality
## 1. Role-Based Access Control
Defined roles such as Admin, Oracle, and DAO participants govern access and interaction with the system.

## 2. Secure, Pausable Registry
The registry includes pausable mechanisms for emergency stops or maintenance, ensuring security and operational control.

## 3. IPFS Justification Storage
Each AI score is backed by a justification stored off-chain via IPFS, enabling full traceability and auditability.

## 4. Dispute Resolution Capabilities
The architecture supports future implementation of score challenge windows and dispute mechanisms.

## 🚀 Scalability & Extensibility
The system is designed to integrate seamlessly into CrossFi’s broader treasury infrastructure and can be extended across chains or integrated into DAO voting systems.

## 🗂 Project Structure
CrossFi-Treasury-Guard/
│
├── abis/                         # Compiled contract ABIs (for frontends and testing)
│   ├── AIScoreRegistry.abi.json
│   ├── ExtendedAccessControl.abi.json
│   ├── ProposalRegistry.abi.json
│   └── TreasuryEscrow.abi.json
│
├── contracts/                    # Solidity smart contracts
│   ├── interfaces/              # Contract interfaces for modularity
│   │   ├── IAIScoreRegistry.sol
│   │   ├── IProposalRegistry.sol
│   │   └── ITreasuryEscrow.sol
│   │
│   ├── utils/                   # Utility contracts (e.g., reusable access control)
│   │   └── ExtendedAccessControl.sol
│   │
│   ├── AIScoreRegistry.sol      # Core AI score registry contract
│   ├── ProposalRegistry.sol     # Proposal management logic
│   ├── ProposalRegistryBase.sol
│   ├── ProposalSubmission.sol   # Proposal submission handler
│   ├── ProposalVoting.sol       # Voting mechanisms (DAO compatible)
│   └── TreasuryEscrow.sol       # Handles fund allocation and escrow
│
├── docs/                         # Documentation
│   └── ContractDocumentation.md
│
├── README.md                     # Project overview and instructions
└── compiler_config.json          # Compiler settings (Solidity 0.8.20)

## 🧪 Manual Testing with Remix
At this stage, the contracts are best tested using the Remix IDE.

## 🔧 Setup Instructions
## 1. Open Remix
Navigate to: https://remix.ethereum.org

## 2. Create Contract Files
Recreate the folder and file structure shown above under the contracts/ directory, and paste each contract’s code into the appropriate file.

## 3. Compile Contracts
Select Solidity compiler version: 0.8.20

Enable optimization with 200 runs

## 4. Deploy AIScoreRegistry.sol
Choose environment: JavaScript VM (for local testing) or CrossFi Testnet

## Deploy the contract and take note of the deployed address

## ⚙️ Interact with Core Functions
## | Function                                                                              | Description                                                                                      |
| ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `submitAIScore(proposalId, overallScore, justificationIPFS, modelVersion, breakdown)` | Allows an authorized Oracle to submit an AI score with metadata and justification stored in IPFS |
| `getAIScore(proposalId)`                                                              | Retrieves the AI score details for a specific proposal                                           |
| `setOracleAuthorization(address, bool)`                                               | Grants or revokes Oracle permissions (Admin only)                                                |
| `pause()` / `unpause()`                                                               | Toggles the contract’s paused state for emergency control (Admin only)                           |


## 📌 Tip: Use the Remix logs to verify emitted events such as AIScoreSubmitted, and inspect contract state changes using the built-in debugger.

