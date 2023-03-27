// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TokenDealer is AccessControl{
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    //Called by DelayHandler to pay out the delayed flight refunds.
    function refundTokens(address _token, address _to, uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(_token).transfer(_to, _amount);
    }
}





// Contract stores the tokens that are used to pay out the delayed flight refunds and executes the aforementioned refunds.

