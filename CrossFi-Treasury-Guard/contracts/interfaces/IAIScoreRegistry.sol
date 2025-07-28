// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IAIScoreRegistry
 * @dev Interface for AIScoreRegistry contract
 */
interface IAIScoreRegistry {
    
    struct ScoringBreakdown {
        uint8 ecosystemScore;
        uint8 feasibilityScore;
        uint8 riskScore;
        uint8 teamScore;
        uint8 innovationScore;
    }
    
    // Events
    event AIScoreSubmitted(
        uint256 indexed proposalId,
        uint256 overallScore,
        string justificationIPFS,
        string modelVersion,
        address indexed oracle,
        uint256 timestamp
    );
    
    // Functions
    function submitAIScore(
        uint256 proposalId,
        uint256 overallScore,
        string memory justificationIPFS,
        string memory modelVersion,
        ScoringBreakdown memory breakdown
    ) external;
    
    function getAIScore(uint256 proposalId) external view returns (
        uint256 score,
        string memory justification,
        bool exists
    );
    
    function hasAIScore(uint256 proposalId) external view returns (bool exists);
}
