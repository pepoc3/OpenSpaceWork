// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "./NFTMarket.sol";

interface TokenRecipient {
    
    function tokensReceived(address _address, uint _amount) external returns (bool);
}

contract ERC20{
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 
    mapping (address => mapping (address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000*(10**decimals);
        balances[msg.sender] = totalSupply;  
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(_value <= balances[msg.sender], "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(_value <= allowances[_from][msg.sender], "ERC20: transfer amount exceeds allowance");
        require(_value <= balances[_from], "ERC20: transfer amount exceeds balance");
        allowances[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function transferWithCallback(address recipient, uint256 amount) external returns (bool) {
        require(amount <= balances[msg.sender], "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        
        if (isContract(recipient)) {
        bool rv = TokenRecipient(recipient).tokensReceived(msg.sender, amount);
        require(rv, "No tokensReceived");
        }

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // write your code here
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // write your code here     
        return allowances[_owner][_spender];
    }

     function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}