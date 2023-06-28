// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IBoardingValidator {
    function checkIn(bytes32 _flightId) external;
    function validateBoardingPass(bytes32 _flightId) external view returns(bool);
    function setTicketManager(address _ticketManager) external;
    function setBoardingPassContract(address _boardingPassContractAddress) external;
}

