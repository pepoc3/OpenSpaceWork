// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
contract RNT is ERC20Permit("RenftToken"){
    constructor()ERC20("Renft token","RNT"){
        _mint(msg.sender,21_000_000 * 1e18);
    }
}