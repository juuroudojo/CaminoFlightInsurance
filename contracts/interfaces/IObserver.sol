// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IObserver {
    function update(bytes32 _id, uint256 _price) external;
}