// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRefundHandler {
    event Refund(address indexed _to, uint256 _amount);

    function handleRefund(uint256 _flightId) external;
    function setRefundRate(uint256 _refundRate) external;
    function setTicketManager(address _ticketManager) external;
    function setFlightManager(address _flightManager) external;
}
