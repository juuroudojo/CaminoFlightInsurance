// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract RefundHandler is AccessControl{
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
    * @dev Processes the info, refunds users whose subscriptions meet the conditions
    */
    function refund(bytes32 _flightId, uint256 _status, uint256 _delay ) external onlyRole(DEFAULT_ADMIN_ROLE){
        
    }

    /**
    * @dev Handles flights which were successfully completed
    * @param _flightId flight id
    */
    function completeFlight(bytes32 _flightId) external onlyRole(DEFAULT_ADMIN_ROLE){
    }
}