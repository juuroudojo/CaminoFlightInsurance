// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TokenDealer is AccessControl{
    event Refund(address indexed _token, address indexed _to, uint256 _amount);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // TEST ONLY
    function withdraw(address _token, address _to, uint256 _amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(_token).transfer(_to, _amount);
    }

    receive() external payable {
    }
}



