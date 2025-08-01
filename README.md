# 🛡️ CrossFi Treasury Guard – AI Score Registry

A secure, modular, and decentralized smart contract system that registers and verifies AI-generated scores for DAO proposals within the CrossFi ecosystem. This contract powers AI-based governance by anchoring scoring transparency, IPFS-backed justification, and role-secured submissions — forming the intelligent core of the Treasury Guard framework.

---

## 🚀 Key Features

### 🔍 AI-Powered Scoring  
Evaluates DAO proposals through verifiable AI-generated scores. Each score includes granular breakdowns (feasibility, impact, utility, etc.) and a justification hash stored on IPFS.

### 🔐 Role-Based Access Control  
Permissions are managed through OpenZeppelin’s AccessControl, extended with a modular authorization layer for Oracles, Admins, and system contracts.

### ⏸️ Emergency Pausing  
Admins can pause the contract in the event of anomalies, ensuring operational safety during upgrades, bug resolution, or external threats.

### 📁 Decentralized IPFS Integration  
AI justifications are stored on IPFS, making the evaluation immutable and publicly accessible for community review and audit.

### ⚖️ Dispute-Ready Architecture  
The system is designed to support future dispute mechanisms where community members or auditors can flag or challenge submitted scores.

---

## 🎯 Hackathon Goal & Ecosystem Fit

This component is designed for the **CrossFi Hackathon 2025** and aligns with the mission of upgrading decentralized treasury governance through:

- ✅ Verifiable AI-based proposal evaluation  
- ✅ Transparent and decentralized recordkeeping  
- ✅ Secure, modular, and upgrade-friendly smart contract architecture  
- ✅ Full compatibility with the CrossFi chain and governance dashboard

---

## 📁 Project Structure

```bash
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


