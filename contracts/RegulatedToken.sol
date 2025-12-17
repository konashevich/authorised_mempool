// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SanctionGuard.sol";

/**
 * @title RegulatedToken
 * @dev An ERC20 token that enforces validator compliance on EVERY transfer.
 * This ensures that no token movement can be processed by a sanctioned validator.
 */
contract RegulatedToken is ERC20, Ownable, SanctionGuard {
    constructor(
        string memory name, 
        string memory symbol, 
        address _registry, 
        address _initialOwner
    ) 
        ERC20(name, symbol) 
        Ownable(_initialOwner) 
        SanctionGuard(_registry) 
    {
        _mint(_initialOwner, 1000000 * 10 ** decimals());
    }

    /**
     * @dev Override of the ERC20 internal update function.
     * This hook is called on mint, burn, and transfer operations.
     * By adding `_checkValidatorCompliance()`, we ensure that NO state change
     * can occur in a block produced by an unauthorised validator.
     */
    function _update(address from, address to, uint256 value) internal virtual override {
        // 1. Enforce Validator Compliance
        _checkValidatorCompliance();

        // 2. Proceed with standard transfer logic
        super._update(from, to, value);
    }
}
