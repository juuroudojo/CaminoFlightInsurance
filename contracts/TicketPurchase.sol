// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/ITicketManager.sol";
import "./interfaces/IFlightManager.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TicketPurchase is AccessControl{
    IFlightManager public flightManager;
    ITicketManager public ticketManager;
    address private tokenDealer;
    address public token;

    constructor(address _flightManager, address _ticketManager, address _tokenDealer, address _token) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        flightManager = IFlightManager(_flightManager);
        ticketManager = ITicketManager(_ticketManager);
        tokenDealer = _tokenDealer;
        token = _token;

        grantRole(DEFAULT_ADMIN_ROLE, _ticketManager);
        grantRole(DEFAULT_ADMIN_ROLE, _flightManager);
    }

    /**
    * @dev Purchase a ticket for a flight, called by the user
    * @param _flightId flight id
    * @param _seat seat number
    */
    function purchaseTicket(bytes32 _flightId, uint256 _seat) external payable {
        (, , uint256 seats, uint256 price) = flightManager.getFlightInfo(_flightId);

        require(seats > 0, "Flight is not active");
        require(_seat>0 && _seat<=seats, "Incorrect seat number");
        require(flightManager.isSeatAvailable(_flightId, _seat), "Seat is taken");

        IERC20(token).transferFrom(msg.sender, tokenDealer, price);

        flightManager.updateFlightInfo(_flightId, _seat, msg.sender);
        ticketManager.addTicket(msg.sender, _flightId, _seat, price);
    }

    function setFlightManager(address _flightManager) external onlyRole(DEFAULT_ADMIN_ROLE) {
        flightManager = IFlightManager(_flightManager);
    }

    function setTicketManager(address _ticketManager) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ticketManager = ITicketManager(_ticketManager);
    }

    function setTokenDealer(address _tokenDealer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenDealer = _tokenDealer;
    }

    function setToken(address _token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        token = _token;
    }
}
