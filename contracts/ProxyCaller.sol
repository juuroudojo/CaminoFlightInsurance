// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ProxyCaller {
    address private _boardingPassAddress;
    address private _flightInformationAddress;
    address private _ticketPurchaseAddress;

    constructor(address boardingPassAddress, address flightInformationAddress, address ticketPurchaseAddress) {
        _boardingPassAddress = boardingPassAddress;
        _flightInformationAddress = flightInformationAddress;
        _ticketPurchaseAddress = ticketPurchaseAddress;
    }

    function checkAndUpdate() public {
        BoardingPass boardingPass = BoardingPass(_boardingPassAddress);

        if (!boardingPass.isMinted(msg.sender)) {
            boardingPass.mint();
        }

        if (boardingPass.isClaimed(msg.sender)) {
            FlightInformation(_flightInformationAddress).updateAddress(msg.sender);
            TicketPurchase(_ticketPurchaseAddress).updateAddress(msg.sender);
            boardingPass.isClaimed(msg.sender) = false;
        }
    }
}

interface FlightInformation {
    function updateAddress(address newAddress) external;
}

interface TicketPurchase {
    function updateAddress(address newAddress) external;
}
