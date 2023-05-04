// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/ITicketManager.sol";


contract BoardingValidator is AccessControl {
    address public ticketManager;

    mapping (address => mapping(bytes32 => bool)) public checkedIn;

    event CheckedIn(address indexed user, bytes32 flightId, uint256 time);

    constructor(address _ticketManager) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        ticketManager = _ticketManager;
    }

    /**
    * @dev Passenger calls the function when checking in
    * @param _flightId flight id
    */
    function checkIn(bytes32 _flightId) public {
        ITicketManager(ticketManager).checkIn(_flightId, msg.sender);
    }

    /**
    * @dev Passenger calls when boarding the plane, having previously checked in
    * @param _flightId flight id
    */
    function validateBoardingPass(bytes32 _flightId) public {
        ITicketManager(ticketManager).useTicket(_flightId, msg.sender);
    }

    /**
    * @dev Admin function to update the address of the ticket manager
    * @param _ticketManager address of the ticket manager
    */
    function setTicketManager(address _ticketManager) external onlyRole(DEFAULT_ADMIN_ROLE){
        ticketManager = _ticketManager;
    }

}
