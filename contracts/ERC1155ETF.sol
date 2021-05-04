// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155ETF is ERC1155Pausable, Ownable {
    constructor(string memory uri_) public ERC1155(uri_) {}

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        _mint(account, id, amount, data);
    }
}
