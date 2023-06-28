// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IAddressLog {
    function updateAddress(address user, address newAddress) external;
    function hasUpdated(address user) external view returns (bool);
    function getNewAddr(address user) external view returns (address);
}
