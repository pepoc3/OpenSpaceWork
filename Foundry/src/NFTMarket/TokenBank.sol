// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC20.sol";

contract TokenBank {
    mapping(address => uint256) public userBalances;
    ERC20 public erc20;
    constructor(address _tokenContract) {
        erc20 = ERC20(_tokenContract);
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        return userBalances[_owner];
    }

    function deposit(uint256 _value) public {

        erc20.transferFrom(msg.sender, address(this), _value);
        userBalances[msg.sender] += _value;
    }

    function withdraw(uint256 _value) public {
        require(_value <= userBalances[msg.sender], "transfer amount exceeds balance");
        erc20.transfer(msg.sender, _value);
        userBalances[msg.sender] -= _value;
    }
    function tokensReceived(address _useraddress, uint256 _value) public returns (bool){
        require(msg.sender == address(erc20), "tokensReceived function should be called by ERC20 contract!");
        userBalances[_useraddress] += _value;
        return true;
    }
    
}