// SPDX-license-identifier: MIT

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FlightManager {
    struct Flight {
        uint256 id;
        string departureAirport;
        string arrivalAirport;
        uint256 departureTime;
        uint256 arrivalTime;
        uint256 price;
        uint256 totalSeats;
        uint256 availableSeats;
    }

    mapping(uint256 => Flight) public flights;

    function addFlight(
        uint256 _id,
        string memory _departureAirport,
        string memory _arrivalAirport,
        uint256 _departureTime,
        uint256 _arrivalTime,
        uint256 _price,
        uint256 _totalSeats
    ) external {
        flights[_id] = Flight(
            _id,
            _departureAirport,
            _arrivalAirport,
            _departureTime,
            _arrivalTime,
            _price,
            _totalSeats,
            _totalSeats
        );
    }

    function updateFlightAvailableSeats(uint256 _id, uint256 _seats) external {
        flights[_id].availableSeats = _seats;
    }

    function isFlightAvailable(uint256 _id) external view returns (bool) {
        return flights[_id].availableSeats > 0;
    }

    function getFlight(uint256 _id)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        return (
            flights[_id].departureTime,
            flights[_id].arrivalTime,
            flights[_id].id,
            flights[_id].availableSeats,
            flights[_id].price,
            flights[_id].availableSeats > 0
        );
    }
}


