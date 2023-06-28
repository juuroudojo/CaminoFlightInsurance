// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract FlightManager is AccessControl {

    event FlightAdded(bytes32 _id, string _departureAirport, string _arrivalAirport, uint256 _departureTime, uint256 _arrivalTime, uint256 _price, uint256 _totalSeats);

    struct Flight {
        bytes32 id;
        string departureAirport;
        string arrivalAirport;
        uint256 departureTime;
        uint256 arrivalTime;
        uint256 price;
        uint256 totalSeats;
        uint256 availableSeats;
        address[] passengers;
    }

    // flightID => FlightInfo
    mapping(bytes32 => Flight) public flights;
    // flightID => seat => is seat taken
    mapping(bytes32 => mapping(uint256 => bool)) public seatTaken;
    
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /** 
    * @dev Called by the owners of the contract to add a flight
    * @param _id flight id
    * @param _departureAirport departure airport
    * @param _arrivalAirport arrival airport
    * @param _departureTime departure time
    * @param _arrivalTime arrival time
    * @param _price price of the ticket
    * @param _totalSeats total seats available
    */
    function addFlight(
        bytes32 _id,
        string memory _departureAirport,
        string memory _arrivalAirport,
        uint256 _departureTime,
        uint256 _arrivalTime,
        uint256 _price,
        uint256 _totalSeats
    ) external onlyRole(DEFAULT_ADMIN_ROLE){
        address[] memory passengers = new address[](_totalSeats);
        flights[_id] = Flight(
            _id,
            _departureAirport,
            _arrivalAirport,
            _departureTime,
            _arrivalTime,
            _price,
            _totalSeats,
            _totalSeats,
            passengers
        );

        emit FlightAdded(_id, _departureAirport, _arrivalAirport, _departureTime, _arrivalTime, _price, _totalSeats);
    }

    /**
    * @dev Called by TicketPurchase to update the flight info every time a ticket is purchased
    * @param _id flight id
    * @param _seat seat number
    * @param _passenger passenger address
    */
    function updateFlightInfo(bytes32 _id, uint256 _seat, address _passenger) onlyRole(DEFAULT_ADMIN_ROLE) external {
        seatTaken[_id][_seat] = true;
        flights[_id].availableSeats--;
        // XD
        flights[_id].passengers[flights[_id].totalSeats - flights[_id].availableSeats - 1] = _passenger;
    }

    /** @dev View function to check if a flight is available
    * @param _id flight id
    * @return true if flight is available
    */
    function isFlightAvailable(bytes32 _id) external view returns (bool) {
        return flights[_id].availableSeats > 0;
    }

    /**
    * @dev View function to retrieve the available seats for a flight
    * @param _flightId flight id
    * @return array of available seats
    */
    function getAvailableSeats(bytes32 _flightId) public view returns (uint256[] memory) {
        Flight memory f = flights[_flightId];
        uint256 totalSeats = f.totalSeats;
        uint256[] memory availableSeats = new uint256[](totalSeats);
        uint256 availableSeatsCount = 0;

        for (uint256 i = 0; i < totalSeats; i++) {
            if (isSeatAvailable(_flightId, i)) {
                availableSeats[availableSeatsCount] = i;
                availableSeatsCount++;
            }
        }

        // resizes the availableSeats array to the number of available seats
        assembly {
            mstore(availableSeats, availableSeatsCount)
        }

        return availableSeats;
    }

    /**
    * @dev View function to check if a seat is available
    * @param _flightId flight id
    * @param _seat seat number
    * @return true if seat is available
    */
    function isSeatAvailable(bytes32 _flightId, uint256 _seat) public view returns (bool) {
        return !seatTaken[_flightId][_seat];
    }

    /** @dev View function to retrieve flight details
    * @param _id flight id
    * @return departureTime, departureTime, arrivalTIme, totalSeats, price
    */
    function getFlightInfo(bytes32 _id)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Flight memory f = flights[_id];
        return (
            f.departureTime,
            f.arrivalTime,
            f.totalSeats,
            f.price
        );
    }
    /**
    * @dev View function to retrieve data needed for refund calculation
    * @param _id flight id
    * @return passengers array of passenger addresses
    * @return price price of the ticket
    */
    function getRefundInfo(bytes32 _id) external view returns (address[] memory, uint256 price, uint256) {
        return (flights[_id].passengers, flights[_id].price, flights[_id].totalSeats - flights[_id].availableSeats);
    }

    /**
    * @dev View function to check if a flight is eligible for check-in
    * @param _flightId flight id
    * @return true if check-in is enabled
    */
    function canCheckIn(bytes32 _flightId) external view returns (bool) {
        // return (block.timestamp + 7200 >=flights[_flightId].departureTime && block.timestamp <= flights[_flightId].departureTime);
        return block.timestamp <= flights[_flightId].departureTime;
    }
}

