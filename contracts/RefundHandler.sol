// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ITicketManager.sol";
import "./interfaces/IFlightManager.sol";
import "./interfaces/ITicketPurchase.sol";

contract RefundHandler is AccessControl {
    ITicketManager ticketManager;
    IFlightManager flightManager;
    ITicketPurchase ticketPurchase;

    event Refund(address indexed _to, uint256 _amount);

    address private tokenDealer;
    uint256 public refundRate;

    constructor(
        address _ticketManager,
        address _flightManager
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        ticketManager = ITicketManager(_ticketManager);
        flightManager = IFlightManager(_flightManager);
    }

    /**
    * @dev Called by FlightObserver compiling the data needed to handle the post flight refund
    * @param _flightId flight id
    */
    function handleRefund(bytes32 _flightId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        (address[] memory p, uint price) = flightManager.getRefundInfo(_flightId);
        price = price * refundRate / 100;
        for (uint256 i = 0; i < p.length; i++) {
            IERC20(ticketPurchase.token()).transferFrom(tokenDealer, p[i], price);

            emit Refund(p[i], price);
        }
    }

    function setRefundRate(uint256 _refundRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        refundRate = _refundRate;
    }

    function setTicketManager(address _ticketManager) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ticketManager = ITicketManager(_ticketManager);
    }

    function setFlightManager(address _flightManager) external onlyRole(DEFAULT_ADMIN_ROLE) {
        flightManager = IFlightManager(_flightManager);
    }
}
