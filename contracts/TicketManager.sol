// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./interfaces/ITicketManager.sol";
import "./interfaces/IFlightManager.sol";


// Contract is called by PurchaseTicket contract.
contract TicketManager is AccessControl {
    address public flightManager;

    struct Ticket {
        uint256 price;
        uint256[] seats;
        bool used;
        bool checkedIn;
    }

    // Boarding pass ID to flightID to ticket
    mapping(address=>mapping(bytes32=>Ticket)) public tickets;


    event TicketPurchased(
        address indexed buyer,
        bytes32 indexed flightId, 
        uint256 price
    );

    event TicketCheckedIn(
        bytes32 indexed flightId,
        address indexed user
    );

    event TicketUsed(
        address indexed user,
        bytes32 indexed flightId,
        uint256[] seats
    );

    /**
    *@dev Stores info about the ticket, called by the PurchaseTicket contract
    *@param _buyer address of the buyer
    *@param _flightId flight id
    *@param _seat seat number
    *@param _price price of the ticket
    */
    function addTicket(
        address _buyer, 
        bytes32 _flightId, 
        uint256 _seat, 
        uint256 _price
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        Ticket storage t = tickets[_buyer][_flightId];
        t.price = _price;
        t.seats.push(_seat);

        emit TicketPurchased(_buyer, _flightId, _price);
    }

    // @dev Check in a passenger, called by BoaringValidator contract
    function checkIn(bytes32 _flightId, address _user) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(canCheckIn(_user, _flightId), "Cannot check in");

        Ticket storage t = tickets[_user][_flightId];

        require(t.checkedIn == false, "Ticket already checked in");

        t.checkedIn = true;

        emit TicketCheckedIn(_flightId, _user);
    }

    // @dev Use a ticket, called by the BoardingValidator contract
    function useTicket(bytes32 _flightId, address _user) public onlyRole(DEFAULT_ADMIN_ROLE){
        Ticket storage t = tickets[_user][_flightId];

        // All needed checks are done when checking in
        require(t.checkedIn, "Ticket not checked in");
        require(!t.used, "Ticket already used");

        t.used = true;

        emit TicketUsed(msg.sender, _flightId, t.seats);
    }

    // @dev View function, returns the seats user has purchased for a flight
    function getSeats(address _user, bytes32 _flightID) public view returns (uint256[] memory) {
        uint256[] memory seats = tickets[_user][_flightID].seats;
        return seats;
    }

    // Checks if passenger has a ticket and if it's not too late to check in
    function canCheckIn(address _user, bytes32 _flightID) public view returns (bool) {
        return tickets[_user][_flightID].seats.length > 0 && IFlightManager(flightManager).canCheckIn(_flightID);
    }
}
