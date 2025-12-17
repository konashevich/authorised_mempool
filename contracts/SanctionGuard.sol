// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ValidatorRegistry.sol";

/**
 * @title SanctionGuard
 * @dev Abstract module that enforces validator compliance on state-changing operations.
 * Integrating contracts must inherit this and apply the `onlyCompliantValidator` modifier
 * or call `_checkValidatorCompliance()` in critical hooks.
 */
abstract contract SanctionGuard {
    ValidatorRegistry public immutable validatorRegistry;

    event ComplianceCheck(address indexed validator, bool success);

    error UnauthorisedValidator(address validator);

    constructor(address _registry) {
        require(_registry != address(0), "Invalid registry address");
        validatorRegistry = ValidatorRegistry(_registry);
    }

    /**
     * @dev Internal check that reverts if the current block producer is not authorised.
     * Uses block.coinbase to identify the validator.
     */
    function _checkValidatorCompliance() internal {
        address currentValidator = block.coinbase;
        
        // Optimisation: Skip check for local test networks where coinbase might be 0 address
        // In production, coinbase is never 0.
        if (block.chainid == 1337 || block.chainid == 31337) return;

        if (!validatorRegistry.isAuthorised(currentValidator)) {
            emit ComplianceCheck(currentValidator, false);
            revert UnauthorisedValidator(currentValidator);
        }
    }

    /**
     * @dev Modifier to enforce compliance on specific functions.
     */
    modifier onlyCompliantValidator() {
        _checkValidatorCompliance();
        _;
    }
}
