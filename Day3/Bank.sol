// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public owner;
    mapping(address => uint256) public balances;
    address[] public topThreeDepositAddresses;
    // uint256[] public topThreeDepositAmounts;

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
        uint amount = msg.value ;
        require(msg.value  > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
        updateTopThreeDepositAddresses(msg.sender, balances[msg.sender]);
    }

    function withdraw() external onlyOwner payable{

        payable(msg.sender).transfer(msg.value);
        balances[msg.sender] -= msg.value;
        emit Withdrawal(msg.sender, msg.value);
        updateTopThreeDepositAddresses(msg.sender, balances[msg.sender]);
    }

     function updateTopThreeDepositAddresses(address _address, uint256 _amount) internal {
        if (topThreeDepositAddresses.length < 3) {
            topThreeDepositAddresses.push(_address);
            // topThreeDepositAmounts.push(_amount);
            sortTopThreeDepositAddresses();
        } else {
            uint256 minAmount = balances[topThreeDepositAddresses[0]];
            uint256 minAmountIndex = 0;
            for (uint256 i = 1; i < topThreeDepositAddresses.length; i++) {
                if (balances[topThreeDepositAddresses[i]] < minAmount) {
                    minAmount = balances[topThreeDepositAddresses[i]];
                    minAmountIndex = i;
                }
            }
            if (_amount > minAmount) {
                topThreeDepositAddresses[minAmountIndex] = _address;
                // topThreeDepositAmounts[minAmountIndex] = _amount;
                sortTopThreeDepositAddresses();
            }
        }
    }

    function sortTopThreeDepositAddresses() internal {
        for (uint256 i = 0; i < topThreeDepositAddresses.length - 1; i++) {
            for (uint256 j = i + 1; j < topThreeDepositAddresses.length; j++) {
                if (balances[topThreeDepositAddresses[i]] < balances[topThreeDepositAddresses[j]]) {
                    // (balances[topThreeDepositAddresses[i]], balances[topThreeDepositAddresses[j]]) = (balances[topThreeDepositAddresses[j]], balances[topThreeDepositAddresses[i]]);
                    (topThreeDepositAddresses[i], topThreeDepositAddresses[j]) = (topThreeDepositAddresses[j], topThreeDepositAddresses[i]);
                }
            }
        }
    }

    function getTopThreeDeposit() external view returns (address, uint256,address, uint256,address, uint256) {
        return (topThreeDepositAddresses[0], balances[topThreeDepositAddresses[0]],topThreeDepositAddresses[1], balances[topThreeDepositAddresses[1]],topThreeDepositAddresses[2], balances[topThreeDepositAddresses[2]]);
        // return (topThreeDepositAddresses[1], balances[topThreeDepositAddresses[1]]);
    }
}

