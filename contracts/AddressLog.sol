// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract AddressLog is AccessControl{
    mapping(address => address) public _updatedAddr;
    mapping(address => bool) public _hasupdated;

    function updateAddress(address user, address newAddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        // TODO: handle the case when user updates his address multiple times
        _updatedAddr[user] = newAddress;
        _hasupdated[user] = true;
    }

    function hasUpdated(address user) public view returns (bool) {
        return _hasupdated[user];
    }

    function getNewAddr(address user) public view returns (address) {
        return _updatedAddr[user];
    }
}
