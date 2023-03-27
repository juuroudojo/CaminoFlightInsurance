// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITicketPurchase {
    function purchaseTicket(uint256 _flightId, uint256 _seat) external payable;
}
