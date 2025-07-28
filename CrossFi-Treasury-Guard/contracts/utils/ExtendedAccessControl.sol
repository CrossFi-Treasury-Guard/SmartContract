// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AccessControl
 * @dev Extended access control with custom roles for CrossFi Treasury Guard
 */
contract ExtendedAccessControl is AccessControl {
    
    // Custom roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant AI_ORACLE_ROLE = keccak256("AI_ORACLE_ROLE");
    bytes32 public constant TREASURY_MANAGER_ROLE = keccak256("TREASURY_MANAGER_ROLE");
    bytes32 public constant MILESTONE_APPROVER_ROLE = keccak256("MILESTONE_APPROVER_ROLE");
    bytes32 public constant DISPUTE_RESOLVER_ROLE = keccak256("DISPUTE_RESOLVER_ROLE");
    
    constructor() {
         _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    /**
     * @dev Grant multiple roles to an account
     * @param account Account to grant roles to
     * @param roles Array of role identifiers
     */
    function grantMultipleRoles(address account, bytes32[] memory roles) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < roles.length; i++) {
            grantRole(roles[i], account);
        }
    }
    
    /**
     * @dev Revoke multiple roles from an account
     * @param account Account to revoke roles from
     * @param roles Array of role identifiers
     */
    function revokeMultipleRoles(address account, bytes32[] memory roles) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < roles.length; i++) {
            revokeRole(roles[i], account);
        }
    }
    
    /**
     * @dev Check if account has any of the specified roles
     * @param account Account to check
     * @param roles Array of role identifiers
     * @return hasAnyRole True if account has at least one of the roles
     */
    function hasAnyRole(address account, bytes32[] memory roles) external view returns (bool) {
        for (uint256 i = 0; i < roles.length; i++) {
            if (hasRole(roles[i], account)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @dev Get all roles for an account
     * @param account Account to check
     * @return roleCount Number of roles the account has
     */
    function getRoleCount(address account) external view returns (uint256 roleCount) {
        bytes32[] memory allRoles = getAllRoles();
        uint256 count = 0;
        
        for (uint256 i = 0; i < allRoles.length; i++) {
            if (hasRole(allRoles[i], account)) {
                count++;
            }
        }
        
        return count;
    }
    
    /**
     * @dev Get all available roles
     * @return roles Array of all role identifiers
     */
    function getAllRoles() public pure returns (bytes32[] memory roles) {
        roles = new bytes32[](6);
        roles[0] = DEFAULT_ADMIN_ROLE;
        roles[1] = ADMIN_ROLE;
        roles[2] = AI_ORACLE_ROLE;
        roles[3] = TREASURY_MANAGER_ROLE;
        roles[4] = MILESTONE_APPROVER_ROLE;
        roles[5] = DISPUTE_RESOLVER_ROLE;
        return roles;
    }
}