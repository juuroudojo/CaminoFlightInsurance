// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBoardingPass {
    function mint() external;
    function updateAddress(address newAddress) external;
    function isMinted(address account) external view returns (bool);
}
