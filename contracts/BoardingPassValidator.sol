// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IBoardingPass.sol";
import "./interfaces/ITicketManager.sol";

contract BoardingPassValidator {
    IBoardingPass private boardingPassContract;
    address public ticketManager;

    constructor(address _boardingPassContractAddress) {
        boardingPassContract = IBoardingPass(_boardingPassContractAddress);
    }

    function validateBoardingPass(bytes32 _flightId) public view returns(bool) {
        uint256 passId = boardingPassContract.passIdOf(msg.sender);
        require(passId != 0, "BoardingPassValidator: boarding pass not found");
        ITicketManager(ticketManager).useTicket(passId);
    }
}
