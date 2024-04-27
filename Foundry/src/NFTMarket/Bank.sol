// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
contract Bank {
    mapping(address => uint) public balanceOf;

    event Deposit(address indexed user, uint amount);

    function depositETH() external payable {
        address user = msg.sender;
        uint256 amount = msg.value;
        require(amount > 0, "Deposit amount must be greater than 0");
        balanceOf[user] += amount;
        emit Deposit(user, amount);
    }
}