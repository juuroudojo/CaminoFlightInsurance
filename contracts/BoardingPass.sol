// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interfaces/IAddressLog.sol";

contract BoardingPass is ERC721 {
    mapping(address => bool) private _minted;
    mapping(address => address) public _updatedAddr;
    mapping(address => bool) private _hasupdated;
    address public addrLog;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function mint() public {
        require(!_minted[msg.sender], "BoardingPass: NFT already minted for this address");
        _safeMint(msg.sender, totalSupply() + 1);
        _minted[msg.sender] = true;
    }

    function updateAddress(address newAddress) public {
        require(!_hasupdated[msg.sender], "BoardingPass: address already updated");
        require(!_minted[newAddress], "BoardingPass: new address already has a minted NFT");

        IAddressLog(addrLog).updateAddress(msg.sender, newAddress);

        _burn(msg.sender);
        _safeMint(newAddress, totalSupply() + 1);
    }

    function isMinted(address account) public view returns (bool) {
        return _minted[account];
    }
}
