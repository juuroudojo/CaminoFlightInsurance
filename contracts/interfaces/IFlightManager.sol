// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFlightManager {

    function addFlight(
        bytes32 _id,
        string memory _departureAirport,
        string memory _arrivalAirport,
        uint256 _departureTime,
        uint256 _arrivalTime,
        uint256 _price,
        uint256 _totalSeats
    ) external;

    function updateFlightInfo(bytes32 _id, uint256 _seat, address _passenger) external;

    function isFlightAvailable(bytes32 _id) external view returns (bool);

    function getAvailableSeats(bytes32 _flightId) external view returns (uint256[] memory);

    function isSeatAvailable(bytes32 _flightId, uint256 _seat) external view returns (bool);

    function getFlightInfo(bytes32 _id) external view returns (
        uint256 departureTime,
        uint256 arrivalTime,
        uint256 totalSeats,
        uint256 price
    );

    function getRefundInfo(bytes32 _id) external view returns (
        address[] memory passengers,
        uint256 price,
        uint256 sb
    );

    function canCheckIn(bytes32 _flightId) external view returns (bool);
}

