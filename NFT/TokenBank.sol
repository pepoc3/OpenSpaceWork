// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC20.sol";

contract TokenBank {

    mapping(address => uint256) public userBalances;
    address _erc20addr = 0x9396B453Fad71816cA9f152Ae785276a1D578492; //erc20合约地址
    event Transfer(address indexed from, address indexed to, uint256 value);
    function deposit(uint256 _value) payable public {

        ERC20(_erc20addr).transferFrom(msg.sender, address(this), _value);
        userBalances[msg.sender] += _value;
    }
    function tokensReceived(address _useraddress, uint256 _value) public returns (bool){
        require(msg.sender == _erc20addr, "tokensReceived function should be called by ERC20 contract!");
        userBalances[_useraddress] += _value;
        return true;
    }
    function withdraw(uint256 _value) public {
        require(_value <= userBalances[msg.sender], "transfer amount exceeds balance");
        ERC20(_erc20addr).transfer(msg.sender, _value);
        userBalances[msg.sender] -= _value;
    }

    
}
