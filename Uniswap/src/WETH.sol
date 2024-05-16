// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
contract WETH is ERC20Permit("WETHToken"){
    constructor()ERC20("WETH token","WETH"){
        _mint(msg.sender,1000000 * 1e18);
    }
}