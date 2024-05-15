// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IToken.sol";

contract KK is ERC20, IToken {
    constructor()ERC20("KK token","KK"){
    }
    
    function mint(address to, uint256 amount) external {
        _mint(to,amount);
    }

    
}