// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";


contract Bank {
    address public owner;
    mapping(address => uint256) public userBalances;
    address[3] public top3_;
    event Deposit(address indexed _from, uint256 _amount);
    event Withdrawal(address indexed _to, uint256 _amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function deposit() external payable {
        userBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
        updateTopThree(msg.sender);
    }

    function withdraw(uint a) external onlyOwner {
        require(a <= userBalances[msg.sender], "Insufficient account balance");
        payable(msg.sender).transfer(a);
        userBalances[msg.sender] -= a;
        emit Withdrawal(msg.sender, a);
        updateTopThree(msg.sender);
    }

    function updateTopThree(address _address) internal {


        if (userBalances[_address] <= userBalances[top3_[2]]) {
            return;
        }

         else if (userBalances[_address] <= userBalances[top3_[1]]) {
            // 抢占到第三名
            top3_[2] = _address;
        }
         else if (userBalances[_address] <= userBalances[top3_[0]]) {
            // 抢占到第二名
            top3_[2] = top3_[1];
            top3_[1] = _address;
        }
         else {
            // 抢占到第一名
            top3_[2] = top3_[1];
            top3_[1] = top3_[0];
            top3_[0] = _address;
        }
    }

    function getTopThreeDeposit() external view returns (address, uint256, address, uint256,address, uint256) {
        return (top3_[0], userBalances[top3_[0]], top3_[1], userBalances[top3_[1]],top3_[2], userBalances[top3_[2]]);

    }
}
