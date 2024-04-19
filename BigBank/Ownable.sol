// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./BigBank.sol";
contract Ownable  {
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    event Received(address, uint);
    //合约接收转账函数
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    //Ownable调用 BigBank 的 withdraw(),且只有owner可以调用
    function withdraw(address _counter) external payable onlyOwner{
        BigBank(_counter).withdraw();
    }

}