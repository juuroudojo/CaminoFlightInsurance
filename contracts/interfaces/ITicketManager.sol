// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITicketManager {
    struct Ticket {
        uint256 price;
        uint256[] seats;
        bool used;
        bool checkedIn;
    }

    function addTicket(
        address _buyer,
        bytes32 _flightId,
        uint256 _seat,
        uint256 _price
    ) external;

    function checkIn(bytes32 _flightId, address _user) external;

    function useTicket(bytes32 _flightId, address _user) external;

    function getSeats(address _user, bytes32 _flightID) external view returns (uint256[] memory);

    function canCheckIn(address _user, bytes32 _flightID) external view returns (bool);

    function getPassengers(bytes32 _flightId) external view returns (address[] memory);

    event TicketPurchased(
        address indexed buyer,
        uint256 indexed flightId,
        uint256 price
    );

    event TicketCheckedIn(
        uint256 indexed boardingPassId,
        bytes32 indexed flightId,
        address indexed user
    );

    event TicketUsed(
        address indexed user,
        bytes32 indexed flightId,
        uint256[] seats
    );
}

