// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFlightManager {
    function addFlight(
        uint256 _id,
        string memory _departureAirport,
        string memory _arrivalAirport,
        uint256 _departureTime,
        uint256 _arrivalTime,
        uint256 _price,
        uint256 _totalSeats
    ) external;

    function updateFlightAvailableSeats(uint256 _id, uint256 _seats) external;

    function isFlightAvailable(uint256 _id) external view returns (bool);

    function getFlight(uint256 _id) external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        bool
    );
}
