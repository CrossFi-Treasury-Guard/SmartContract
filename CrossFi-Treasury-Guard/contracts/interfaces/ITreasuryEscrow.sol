// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ITreasuryEscrow
 * @dev Interface for TreasuryEscrow contract handling native XFI coin
 */
interface ITreasuryEscrow {
    
    enum EscrowStatus {
        Active,
        Completed,
        Cancelled
    }
    
    // Events
    event EscrowCreated(
        uint256 indexed proposalId,
        address indexed beneficiary,
        uint256 totalAmount,
        uint256 milestoneCount
    );
    
    event FundsReleased(
        uint256 indexed proposalId,
        uint256 indexed milestoneIndex,
        uint256 amount,
        address indexed beneficiary
    );
    
    function createEscrow(
        uint256 proposalId,
        address beneficiary,
        uint256 totalAmount,
        uint256 milestoneCount
    ) external payable;
    
    function getEscrow(uint256 proposalId) external view returns (
        address beneficiary,
        uint256 totalAmount,
        uint256 releasedAmount,
        uint256 milestoneCount,
        EscrowStatus status,
        uint256 creationTime
    );
    
    function escrowExists(uint256 proposalId) external view returns (bool);
}