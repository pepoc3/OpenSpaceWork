// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MultiSigWallet {
    // Constants
    uint constant public MAX_OWNER_COUNT = 50;

    // State variables
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public required;
    uint public transactionCount;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
        uint confirmationCount;
    }

    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;

    // Events
    event Deposit(address indexed sender, uint value);
    event Submission(uint indexed transactionId);
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);

    // Modifiers
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    modifier txExists(uint transactionId) {
        require(transactions[transactionId].destination != address(0), "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed, "Transaction already executed");
        _;
    }

    modifier notConfirmed(uint transactionId) {
        require(!confirmations[transactionId][msg.sender], "Transaction already confirmed");
        _;
    }

    // Constructor
    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0 && _owners.length <= MAX_OWNER_COUNT, "Invalid number of owners");
        require(_required > 0 && _required <= _owners.length, "Invalid number of required confirmations");

        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner");
            require(!isOwner[_owners[i]], "Owner not unique");
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }

        required = _required;
    }

    // Fallback function to receive ether
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // Public functions
    function submitTransaction(address destination, uint value, bytes memory data) public onlyOwner returns (uint transactionId) {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false,
            confirmationCount: 0
        });
        transactionCount++;
        emit Submission(transactionId);
    }

    function confirmTransaction(uint transactionId) public onlyOwner txExists(transactionId) notExecuted(transactionId) notConfirmed(transactionId) {
        confirmations[transactionId][msg.sender] = true;
        transactions[transactionId].confirmationCount += 1;
        emit Confirmation(msg.sender, transactionId);

        if (transactions[transactionId].confirmationCount >= required) {
            executeTransaction(transactionId);
        }
    }

    function executeTransaction(uint transactionId) public txExists(transactionId) notExecuted(transactionId) {
        if (transactions[transactionId].confirmationCount >= required) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            (bool success, ) = txn.destination.call{value: txn.value}(txn.data);
            if (success) {
                emit Execution(transactionId);
            } else {
                txn.executed = false;
                emit ExecutionFailure(transactionId);
            }
        }
    }

    function getTransaction(uint transactionId) public view returns (address destination, uint value, bytes memory data, bool executed, uint confirmationCount) {
        Transaction storage txn = transactions[transactionId];
        return (txn.destination, txn.value, txn.data, txn.executed, txn.confirmationCount);
    }

    function getConfirmations(uint transactionId) public view returns (address[] memory) {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count++;
            }
        }
        address[] memory _confirmations = new address[](count);
        for (uint i = 0; i < count; i++) {
            _confirmations[i] = confirmationsTemp[i];
        }
        return _confirmations;
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint) {
        return transactionCount;
    }
}
