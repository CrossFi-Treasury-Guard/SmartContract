// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IAIScoreRegistry.sol";
import "./utils/ExtendedAccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title AIScoreRegistry
 * @dev Stores AI-generated scores and IPFS CIDs for proposal analysis
 * @author CrossFi Treasury Guard Team
*/

contract AIScoreRegistry is IAIScoreRegistry, ExtendedAccessControl, Pausable, ReentrancyGuard {

    // scoring..

    struct ScoringCriteria {
        uint8 ecosystemContribution;
        uint8 feasibility;
        uint8 riskAssessment;
        uint8 teamReputation;
        uint8 innovation;
    }

    // data structure

        struct AIScoreData {
        uint256 proposalId;
        uint256 overallScore;
        string justificationIPFS;
        string modelVersion;
        uint256 timestamp;
        address oracle;    
        bool exists;
        ScoringBreakdown breakdown;
    }

    mapping(uint256 => AIScoreData) private aiScores;
    mapping(address => bool) public authorizedOracles;
    mapping(string => bool) public supportedModels;
    
    ScoringCriteria public scoringWeights;
    uint256 public constant MIN_SCORE = 0;
    uint256 public constant MAX_SCORE = 100;
    uint256 public constant SCORE_VALIDITY_PERIOD = 30 days;

    uint256 public totalScoresSubmitted;
    mapping(address => uint256) public oracleScoreCount;

    
    event OracleAuthorized(address indexed oracle, bool authorized);
    event ModelSupported(string modelVersion, bool supported);
    event ScoringCriteriaUpdated(ScoringCriteria newCriteria);
    event ScoreUpdated(uint256 indexed proposalId, uint256 newScore, string reason);

    modifier onlyAuthorizedOracle() {
        require(authorizedOracles[msg.sender], "Not authorized oracle");
        _;
    }

    modifier validScore(uint256 score) {
        require(score >= MIN_SCORE && score <= MAX_SCORE, "Score out of range");
        _;
    }
    
    modifier validProposalId(uint256 proposalId) {
        require(proposalId > 0, "Invalid proposal ID");
        _;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(AI_ORACLE_ROLE, msg.sender);
        
        // Initialize default scoring criteria
        scoringWeights = ScoringCriteria({
            ecosystemContribution: 25,
            feasibility: 25,
            riskAssessment: 20,
            teamReputation: 15,
            innovation: 15
        });
        
        // default supported models
        supportedModels["GPT-4"] = true;
        supportedModels["Claude-3"] = true;
    }

    /**
     * @dev Submit AI-generated score for a proposal
     * @param proposalId The proposal ID
     * @param overallScore Overall AI score (0-100)
     * @param justificationIPFS IPFS CID containing detailed analysis
     * @param modelVersion AI model version used
     * @param breakdown Detailed scoring breakdown
    */

     function submitAIScore(
        uint256 proposalId,
        uint256 overallScore,
        string memory justificationIPFS,
        string memory modelVersion,
        ScoringBreakdown memory breakdown
    ) external override onlyAuthorizedOracle validProposalId(proposalId) validScore(overallScore) whenNotPaused nonReentrant {
        require(bytes(justificationIPFS).length > 0, "Justification IPFS required");
        require(supportedModels[modelVersion], "Unsupported AI model");
        require(!aiScores[proposalId].exists, "Score already exists");
        
        // Validate breakdown scores
        require(
            breakdown.ecosystemScore <= 100 &&
            breakdown.feasibilityScore <= 100 &&
            breakdown.riskScore <= 100 &&
            breakdown.teamScore <= 100 &&
            breakdown.innovationScore <= 100,
            "Invalid breakdown scores"
        );

        uint256 calculatedScore = (
            (breakdown.ecosystemScore * scoringWeights.ecosystemContribution) +
            (breakdown.feasibilityScore * scoringWeights.feasibility) +
            (breakdown.riskScore * scoringWeights.riskAssessment) +
            (breakdown.teamScore * scoringWeights.teamReputation) +
            (breakdown.innovationScore * scoringWeights.innovation)
        ) / 100;

        require(
            overallScore >= calculatedScore - 5 && overallScore <= calculatedScore + 5,
            "Score inconsistent with breakdown"
        );

        aiScores[proposalId] = AIScoreData({
            proposalId: proposalId,
            overallScore: overallScore,
            justificationIPFS: justificationIPFS,
            modelVersion: modelVersion,
            timestamp: block.timestamp,
            oracle: msg.sender,
            exists: true,
            breakdown: breakdown
        });
        
        totalScoresSubmitted++;
        oracleScoreCount[msg.sender]++;
        
        emit AIScoreSubmitted(
            proposalId,
            overallScore,
            justificationIPFS,
            modelVersion,
            msg.sender,
            block.timestamp
        );
    }

     /**
     * @dev Update existing AI score (only within validity period)
     * @param proposalId The proposal ID
     * @param newScore New overall score
     * @param newJustificationIPFS New IPFS CID for updated analysis
     * @param reason Reason for score update
     */
    function updateAIScore(
        uint256 proposalId,
        uint256 newScore,
        string memory newJustificationIPFS,
        string memory reason
    ) external onlyAuthorizedOracle validProposalId(proposalId) validScore(newScore) whenNotPaused {
        require(aiScores[proposalId].exists, "Score does not exist");
        require(aiScores[proposalId].oracle == msg.sender, "Not original oracle");
        require(
            block.timestamp <= aiScores[proposalId].timestamp + SCORE_VALIDITY_PERIOD,
            "Update period expired"
        );
        require(bytes(reason).length > 0, "Update reason required");
        
        aiScores[proposalId].overallScore = newScore;
        aiScores[proposalId].justificationIPFS = newJustificationIPFS;
        aiScores[proposalId].timestamp = block.timestamp;
        
        emit ScoreUpdated(proposalId, newScore, reason);
    }

    /**
     * @dev Get AI score for a proposal
     * @param proposalId The proposal ID
     * @return score Overall AI score
     * @return justification IPFS CID for detailed analysis
     * @return exists Whether score exists
     */
    function getAIScore(uint256 proposalId) external view override validProposalId(proposalId) returns (
        uint256 score,
        string memory justification,
        bool exists
    ) {
        AIScoreData storage scoreData = aiScores[proposalId];
        return (scoreData.overallScore, scoreData.justificationIPFS, scoreData.exists);
    }

    /**
     * @dev Get detailed AI score data
     * @param proposalId The proposal ID
     * @return Complete AI score data structure
     */
    function getDetailedAIScore(uint256 proposalId) external view validProposalId(proposalId) returns (AIScoreData memory) {
        require(aiScores[proposalId].exists, "Score does not exist");
        return aiScores[proposalId];
    }

    /**
     * @dev Get scoring breakdown for a proposal
     * @param proposalId The proposal ID
     * @return breakdown Detailed scoring breakdown
     */
    function getScoringBreakdown(uint256 proposalId) external view validProposalId(proposalId) returns (ScoringBreakdown memory breakdown) {
        require(aiScores[proposalId].exists, "Score does not exist");
        return aiScores[proposalId].breakdown;
    }

    /**
     * @dev Check if AI score exists for a proposal
     * @param proposalId The proposal ID
     * @return exists Whether score exists
     */
    function hasAIScore(uint256 proposalId) external view override validProposalId(proposalId) returns (bool exists) {
        return aiScores[proposalId].exists;
    }

    /**
     * @dev Get oracle statistics
     * @param oracle Oracle address
     * @return scoreCount Number of scores submitted by oracle
     * @return isAuthorized Whether oracle is authorized
     */
    function getOracleStats(address oracle) external view returns (uint256 scoreCount, bool isAuthorized) {
        return (oracleScoreCount[oracle], authorizedOracles[oracle]);
    }

     /**
     * @dev Authorize or deauthorize an AI oracle
     * @param oracle Oracle address
     * @param authorized Authorization status
     */
    function setOracleAuthorization(address oracle, bool authorized) external onlyRole(ADMIN_ROLE) {
        require(oracle != address(0), "Invalid oracle address");
        authorizedOracles[oracle] = authorized;
        
        if (authorized) {
            grantRole(AI_ORACLE_ROLE, oracle);
        } else {
            revokeRole(AI_ORACLE_ROLE, oracle);
        }
        
        emit OracleAuthorized(oracle, authorized);
    }

    /**
     * @dev Add or remove supported AI model
     * @param modelVersion Model version string
     * @param supported Whether model is supported
     */
    function setSupportedModel(string memory modelVersion, bool supported) external onlyRole(ADMIN_ROLE) {
        require(bytes(modelVersion).length > 0, "Invalid model version");
        supportedModels[modelVersion] = supported;
        emit ModelSupported(modelVersion, supported);
    }

    /**
     * @dev Update scoring criteria weights
     * @param newCriteria New scoring criteria
     */
    function updateScoringCriteria(ScoringCriteria memory newCriteria) external onlyRole(ADMIN_ROLE) {
        require(
            newCriteria.ecosystemContribution + 
            newCriteria.feasibility + 
            newCriteria.riskAssessment + 
            newCriteria.teamReputation + 
            newCriteria.innovation == 100,
            "Weights must sum to 100"
        );
        
        scoringWeights = newCriteria;
        emit ScoringCriteriaUpdated(newCriteria);
    }

    /**
     * @dev Emergency function to remove invalid score
     * @param proposalId The proposal ID
     * @param reason Reason for removal
     */
    function removeScore(uint256 proposalId, string memory reason) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(aiScores[proposalId].exists, "Score does not exist");
        require(bytes(reason).length > 0, "Reason required");
        
        delete aiScores[proposalId];
        totalScoresSubmitted--;
        
        emit ScoreUpdated(proposalId, 0, reason);
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}