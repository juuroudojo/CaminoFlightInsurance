// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BoardingPass.sol";


// Contract is called by PurchaseTicket contract.
contract TicketManager {
    struct Ticket {
        uint256 boardingPassId;
        uint256 flightId;
        uint256 price;
        bool used;
    }

    mapping (uint256 => Ticket) public tickets;

    event TicketPurchased(uint256 indexed boardingPassId, uint256 indexed flightId, uint256 price);

    function purchaseTicket(uint256 _boardingPassId, uint256 _flightId, uint256 _price) public {
        // Make sure the boarding pass belongs to the sender
        require(BoardingPass(ownerOf(_boardingPassId)).ownerOf(_boardingPassId) == msg.sender, "Boarding pass not owned by sender");

        // Create a new ticket and store it in the mapping
        tickets[_boardingPassId] = Ticket(_boardingPassId, _flightId, _price, false);

        // Emit an event to indicate the ticket purchase
        emit TicketPurchased(_boardingPassId, _flightId, _price);
    }

    function useTicket(uint256 _boardingPassId) public {
        // Make sure the ticket exists and belongs to the sender
        require(tickets[_boardingPassId].boardingPassId == _boardingPassId, "Ticket does not exist");
        require(BoardingPass(ownerOf(_boardingPassId)).ownerOf(_boardingPassId) == msg.sender, "Ticket not owned by sender");
        require(tickets[_boardingPassId].used == false, "Ticket already used");

        // Mark the ticket as used
        tickets[_boardingPassId].used = true;
    }
}
