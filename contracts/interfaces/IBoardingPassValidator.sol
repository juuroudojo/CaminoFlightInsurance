// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBoardingPassValidator {
    function validateBoardingPass(bytes32 _flightId) external view returns(bool);
}
