// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BankMappingList{

  mapping(address => uint256) public balances;
  mapping(address => address) _nextDepositor;
  uint256 public listSize;
  address constant GUARD = address(1);

  constructor() public {
    _nextDepositor[GUARD] = GUARD;
  }


    // Receive function to accept ETH
    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        // balances[msg.sender] += msg.value;
        uint256 depositValue = msg.value;
        if(balances[msg.sender] == 0) {
        addDepositor(msg.sender, depositValue);
        }
        else {
            depositValue += balances[msg.sender];
            updatedepositValue(msg.sender, depositValue);
        }
    }

  function addDepositor(address depositor, uint256 depositValue) public {
    require(_nextDepositor[depositor] == address(0));
    address index = _findIndex(depositValue);
    balances[depositor] = depositValue;
    _nextDepositor[depositor] = _nextDepositor[index];
    _nextDepositor[index] = depositor;
    listSize++;
  }

  function increasedepositValue(address depositor, uint256 depositValue) public {
    updatedepositValue(depositor, balances[depositor] + depositValue);
  }

  function reducedepositValue(address depositor, uint256 depositValue) public {
    updatedepositValue(depositor, balances[depositor] - depositValue);
  }

  function updatedepositValue(address depositor, uint256 newdepositValue) public {
    require(_nextDepositor[depositor] != address(0));
    address prevdepositor = _findPrevdepositor(depositor);
    address nextdepositor = _nextDepositor[depositor];
    if(_verifyIndex(prevdepositor, newdepositValue, nextdepositor)){
      balances[depositor] = newdepositValue;
    } else {
      removedepositor(depositor);
      addDepositor(depositor, newdepositValue);
    }
  }

  function removedepositor(address depositor) public {
    require(_nextDepositor[depositor] != address(0));
    address prevdepositor = _findPrevdepositor(depositor);
    _nextDepositor[prevdepositor] = _nextDepositor[depositor];
    _nextDepositor[depositor] = address(0);
    balances[depositor] = 0;
    listSize--;
  }

  function getTop(uint256 k) public view returns(address[] memory) {
    require(k <= listSize);
    address[] memory depositorLists = new address[](k);
    address currentAddress = _nextDepositor[GUARD];
    for(uint256 i = 0; i < k; ++i) {
      depositorLists[i] = currentAddress;
      currentAddress = _nextDepositor[currentAddress];
    }
    return depositorLists;
  }


  function _verifyIndex(address prevdepositor, uint256 newValue, address nextdepositor)
    internal
    view
    returns(bool)
  {
    return (prevdepositor == GUARD || balances[prevdepositor] >= newValue) && 
           (nextdepositor == GUARD || newValue > balances[nextdepositor]);
  }

  function _findIndex(uint256 newValue) internal view returns(address) {
    address candidateAddress = GUARD;
    while(true) {
      if(_verifyIndex(candidateAddress, newValue, _nextDepositor[candidateAddress]))
        return candidateAddress;
      candidateAddress = _nextDepositor[candidateAddress];
    }
  }

  function _isPrevdepositor(address depositor, address prevdepositor) internal view returns(bool) {
    return _nextDepositor[prevdepositor] == depositor;
  }

  function _findPrevdepositor(address depositor) internal view returns(address) {
    address currentAddress = GUARD;
    while(_nextDepositor[currentAddress] != GUARD) {
      if(_isPrevdepositor(depositor, currentAddress))
        return currentAddress;
      currentAddress = _nextDepositor[currentAddress];
    }
    return address(0);
  }
} 
