// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC20.sol";

contract TokenBank {

    mapping(address => uint256) public userBalances;
    
    function deposit(address _erc20addr, uint256 _value) public {

        ERC20(_erc20addr).transferFrom(msg.sender, address(this), _value);
        userBalances[msg.sender] += _value;
    }

    function withdraw(address _erc20addr, uint256 _value) public {
        require(_value <= userBalances[msg.sender], "transfer amount exceeds balance");
        ERC20(_erc20addr).transfer(msg.sender, _value);
        userBalances[msg.sender] -= _value;
    }

    
}