🛡️ CrossFi Treasury Guard – AI Score Registry
A secure, modular, and decentralized smart contract system that registers and verifies AI-generated scores for DAO proposals within the CrossFi ecosystem. This contract powers AI-based governance by anchoring scoring transparency, IPFS-backed justification, and role-secured submissions — forming the intelligent core of the Treasury Guard framework.

🚀 Key Features
🔍 AI-Powered Scoring
Evaluates DAO proposals through verifiable AI-generated scores. Each score includes granular breakdowns (feasibility, impact, utility, etc.) and a justification hash stored on IPFS.

🔐 Role-Based Access Control
Permissions are managed through OpenZeppelin’s AccessControl, extended with a modular authorization layer for Oracles, Admins, and system contracts.

⏸ Emergency Pausing
Admins can pause the contract in the event of anomalies, ensuring operational safety during upgrades, bug resolution, or external threats.

📁 Decentralized IPFS Integration
AI justifications are stored on IPFS, making the evaluation immutable and publicly accessible for community review and audit.

⚖️ Dispute-Ready Architecture
The system is designed to support future dispute mechanisms where community members or auditors can flag or challenge submitted scores.

🎯 Hackathon Goal & Ecosystem Fit
This component is designed for the CrossFi Hackathon 2025 and aligns with the mission of upgrading decentralized treasury governance through:

Verifiable AI-based proposal evaluation

Transparent and decentralized recordkeeping

Secure, modular, and upgrade-friendly smart contract architecture

Full compatibility with the CrossFi chain and governance dashboard

📁 Project Structure
bash
Copy
Edit
CrossFi-Treasury-Guard/
│
├── abis/                         # ABI files for frontend or integration
│   ├── AIScoreRegistry.abi.json
│   ├── ExtendedAccessControl.abi.json
│   ├── ProposalRegistry.abi.json
│   └── TreasuryEscrow.abi.json
│
├── contracts/                    # Solidity contracts
│   ├── interfaces/              # Modular interfaces
│   │   ├── IAIScoreRegistry.sol
│   │   ├── IProposalRegistry.sol
│   │   └── ITreasuryEscrow.sol
│   │
│   ├── utils/                   # Shared logic
│   │   └── ExtendedAccessControl.sol
│   │
│   ├── AIScoreRegistry.sol      # AI score management logic
│   ├── ProposalRegistry.sol     # Proposal tracking logic
│   ├── ProposalRegistryBase.sol
│   ├── ProposalSubmission.sol
│   ├── ProposalVoting.sol
│   └── TreasuryEscrow.sol       # Milestone-based fund releases
│
├── docs/                         # Additional documentation
│   └── ContractDocumentation.md
│
├── README.md                     # This project overview
└── compiler_config.json          # Solidity compiler configuration
🧪 Testing in Remix
Manual testing can be done directly via Remix IDE. Automated tests are scheduled for future versions.

✅ Step-by-Step Guide
Open Remix:
➤ https://remix.ethereum.org

Import Files:
Paste the contract files into the contracts/ structure above.

Compiler Settings:

Version: 0.8.20

Optimization: Enabled, Runs: 200

Deploy Contracts in Order:

ExtendedAccessControl.sol

AIScoreRegistry.sol

(Optional for testing): ProposalRegistry.sol, TreasuryEscrow.sol

Choose Environment:

JavaScript VM for quick local testing

Or connect to CrossFi Testnet

🧰 Interacting with the Registry
Function	Description
submitAIScore(proposalId, overallScore, justificationIPFS, modelVersion, breakdown)	Oracle submits an AI score with breakdowns and IPFS hash
getAIScore(proposalId)	Retrieves full score metadata for a proposal
setOracleAuthorization(address, bool)	Grants or revokes Oracle submission rights
pause() / unpause()	Allows Admin to pause or resume registry

📌 Event Logs: Look for AIScoreSubmitted to confirm submissions.

🛠 Compiler Configuration (For Tools like Hardhat)
json
Copy
Edit
{
  "language": "Solidity",
  "sources": {
    "AIScoreRegistry.sol": {
      "content": "<paste-contract-code>"
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
🧨 Common Error: Stack Too Deep
“Stack Too Deep” errors in Remix are common for complex structs or large functions. Here's a helpful resource to address this:

🔗 How to Fix "Stack Too Deep" in Solidity – Recommended Workarounds

Tips:

Break large functions into smaller ones

Use local structs or memory arrays

Minimize inline calculations

📌 Using the Contract Without Verification
Deployment without source-code verification (e.g., on CrossFi Testnet) is fully supported. The contract will function correctly if:

Bytecode matches your compiled output

You’ve imported all dependencies (e.g., OpenZeppelin) locally or flattened

Verification is only required for transparency, not functionality.

🔮 Future Enhancements
Planned Feature	Description
Score Dispute Window	Allow DAO members to challenge submitted scores within a fixed time
On-Chain Model Versioning	Register and track the model version tied to each score
Cross-Chain Deployment	Extend compatibility across other EVM networks
DAO Score Integration	Use AI scores to influence voting weight or filter weak proposals

🔗 Deployed Addresses
Paste your deployed contract addresses below:

ts
Copy
Edit
// src/config/contracts.ts
export const CONTRACT_ADDRESSES = {
  AI_SCORE_REGISTRY: 'PASTE_HERE',
  PROPOSAL_REGISTRY: 'PASTE_HERE',
  TREASURY_ESCROW: 'PASTE_HERE',
  XFI_TOKEN: 'PASTE_HERE'
};
📖 Learn More
To see this contract in action, explore its integration in the CrossFi Treasury Guard – AI-Governed DAO (Frontend) interface.

Submit a proposal

Receive an AI-backed score

Vote and manage treasury funding — all from the frontend dashboard

📝 License
MIT License. See LICENSE for full details.

🧑‍💻 Contributing & Support
Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

✅ Ways to Contribute
Fork the repo

Create a feature branch

Commit changes

Push to GitHub and open a PR

❓ Questions or Bugs?
File an issue on GitHub

Contact the CrossFi Hackathon team

Check the Wiki for additional docs



