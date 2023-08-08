// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

contract FakeUSDC is ERC20, Ownable {
    mapping(address => bool) public minted;

    constructor() ERC20("Fake USD Coin", "fUSDC") {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function mintOnce(address to) external {
        require(!minted[to], "FakeUSDC: already minted");
        minted[to] = true;
        _mint(to, 100e18);
    }
}
