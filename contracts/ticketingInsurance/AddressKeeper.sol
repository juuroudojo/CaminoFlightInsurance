// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract AddressKeeper is AccessControl{
    mapping(address => address) public _updatedAddr;
    mapping(address => bool) public _hasupdated;

    // Camino allows users to have dynamic addresses, meaning that they can change their address at any time.
    // Multiple parts of the system rely on mapping the address to values. To make the process friendlier 
    // this contract allows user to update the info about the address the ecosystem needs to refer to in one call,
    // instead of having manually update info in all the contracts that need to know about the address change.
    // When user updates the address of his wallet he needs to call updateAddress() using the private key of the previous 
    // wallet. This will transfer the ownership and records of the user to the new wallet.
    // @notice: In order to prevent abusing the functionality that is meant to be only called once by user, some benefits 
    // will not be available to those changing their address.

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

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
