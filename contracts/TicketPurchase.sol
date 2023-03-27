// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/ITicketManager.sol";
import "./interfaces/IFlightManager.sol";
import "./interfaces/IPaymentGateway.sol";

contract TicketPurchase {
    IFlightManager public flightManager;
    ITicketManager public ticketManager;
    IPaymentGateway public paymentGateway;

    constructor(address _flightInformation, address _paymentGateway) {
        flightInformation = FlightManager(_flightInformation);
        paymentGateway = PaymentGateway(_paymentGateway);
    }

    function purchaseTicket(uint256 _flightId, uint256 _seat) external payable {
        (uint256 departureTime, uint256 arrivalTime, uint256 flightId, uint256 availableSeats, uint256 price, bool isActive) = flightInformation.getFlight(_flightId);

        require(isActive, "TicketPurchase: Flight is not active");
        require(availableSeats > 0, "TicketPurchase: No available seats");

        paymentGateway.processPayment(msg.sender, price);

        flightInformation.updateFlight(_flightId, availableSeats - 1, availableSeats - 1 == 0 ? false : true);
        ticketManager.addTicket(msg.sender, _flightId, _seat, price);
    }
}
