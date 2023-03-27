// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITicketManager {
    struct Ticket {
        uint256 boardingPassId;
        uint256 flightId;
        uint256 price;
        bool used;
    }

    function purchaseTicket(uint256 _boardingPassId, uint256 _flightId, uint256 _price) external;
    function useTicket(uint256 _boardingPassId) external;
    function tickets(uint256 _boardingPassId) external view returns (Ticket memory);
}
