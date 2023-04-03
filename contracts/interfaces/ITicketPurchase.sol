// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITicketPurchase {
    function purchaseTicket(bytes32 _flightId, uint256 _seat) external payable;
    function setFlightManager(address _flightManager) external;
    function setTicketManager(address _ticketManager) external;
    function setTokenDealer(address _tokenDealer) external;
    function setToken(address _token) external;
    function token() external view returns (address);
}

