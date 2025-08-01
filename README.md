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


## 🧠 Score Dispute Mechanism

A mechanism for decentralizing trust in AI scoring by enabling community oversight.

### 🔍 Why It Matters
AI scores may be incorrect, biased, or misused. A **Score Dispute Window** gives DAO members a chance to **challenge** suspicious or unfair scores before they become final.

---

### ✅ How It Works

1. **Oracle submits AI Score**  
   Includes score, justification (IPFS), and model version metadata.

2. **Dispute Window Opens**  
   Once submitted, a timer begins (e.g., 24–72 hours).

3. **DAO Members Can Dispute**  
   Any wallet with proper access can trigger a dispute by providing evidence and paying a small fee (to prevent spam).

4. **Escalation Process**  
   - Disputed scores are paused.
   - A committee (or DAO vote) resolves the case.
   - Outcome: Score is **confirmed**, **updated**, or **rejected**.

5. **Finalization**  
   If no dispute is raised within the window, the score becomes final.

---

### ⚙️ Proposed Contract Additions

| Function | Description |
|---------|-------------|
| `openDisputeWindow(proposalId)` | Opens dispute window after a score is submitted |
| `disputeScore(proposalId, justificationIPFS)` | DAO member raises a dispute |
| `resolveDispute(proposalId, newScore?)` | Admin or vote-based resolution to finalize score |
| `getDisputeStatus(proposalId)` | Returns current status: `None`, `Open`, `Resolved` |

---

### 📌 Events

| Event | Trigger |
|-------|---------|
| `ScoreDisputed(proposalId, disputer, justificationIPFS)` | Emitted when a score is challenged |
| `DisputeResolved(proposalId, result)` | Emitted when resolution is complete |

---

### 🧰 Optional Parameters

- `disputeFee`: Small ETH fee (e.g., 0.01 ETH) to submit a dispute  
- `windowDuration`: Configurable by admin (e.g., 48 hours)  
- `maxDisputesPerProposal`: Prevent spam or abuse  

---

### 🛡 Example Use Case

A DAO member sees a score of **90/100** submitted to a weak proposal.

- They believe it's inflated.
- They submit a dispute citing flawed model justification.
- A resolution team reviews and adjusts score to **65/100** after investigation.
- System logs everything on-chain and updates transparently.

---

### 🔮 Future Improvements

| Feature | Description |
|---------|-------------|
| 🧠 On-Chain Justification Review | Use zkML or hash-verified LLM models for transparency |
| 🗳 Dispute Voting | Let all DAO members vote on disputes |
| ⚖️ Slashing for Bad Oracles | Penalize repeat offenders submitting bad scores |

---

### 🚀 Benefits

- 📊 Increases transparency of AI scoring  
- 🧑‍⚖️ Empowers community to catch unfair scores  
- ⛓ Fully on-chain and verifiable  
- 🛠 Minimal cost, high integrity  

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
