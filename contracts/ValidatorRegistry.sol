// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title ValidatorRegistry
 * @dev Manages the whitelist of authorised validator fee-recipient addresses.
 * This contract acts as the "Regulated Perimeter" control point.
 */
contract ValidatorRegistry is AccessControl {
    bytes32 public constant REGULATOR_ROLE = keccak256("REGULATOR_ROLE");

    // Mapping from validator fee-recipient address to authorisation status
    mapping(address => bool) private _authorisedValidators;

    event ValidatorStatusUpdated(address indexed validator, bool isAuthorised);

    constructor(address _admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(REGULATOR_ROLE, _admin);
    }

    /**
     * @dev Checks if a validator address is authorised.
     * @param validator The address to check (usually block.coinbase).
     */
    function isAuthorised(address validator) external view returns (bool) {
        return _authorisedValidators[validator];
    }

    /**
     * @dev Updates the authorisation status of a list of validators.
     * Only callable by accounts with REGULATOR_ROLE.
     */
    function updateValidatorStatus(address[] calldata validators, bool status) external onlyRole(REGULATOR_ROLE) {
        for (uint256 i = 0; i < validators.length; i++) {
            _authorisedValidators[validators[i]] = status;
            emit ValidatorStatusUpdated(validators[i], status);
        }
    }
}
