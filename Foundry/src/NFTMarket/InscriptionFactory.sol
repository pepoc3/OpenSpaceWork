// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract InscriptionFactory {
    address payable public owner;
    uint public feePercent; // Percentage of fee to be charged
    
    event InscriptionCreated(address indexed token, string symbol, uint totalSupply, uint perMint, uint price);
    
    constructor(uint _feePercent) {
        owner = payable(msg.sender);
        feePercent = _feePercent;
    }
    
    function deployInscription(string memory symbol, uint totalSupply, uint perMint, uint price) external payable {
        require(msg.value >= price, "Insufficient funds");
        
        // Calculate fee
        uint fee = (msg.value * feePercent) / 100;
        uint amountToMint = (msg.value - fee) / price * perMint;
        
        // Deploy new ERC20 token contract
        ERC20Inscription token = new ERC20Inscription(symbol, totalSupply, perMint);
        
        // Transfer tokens to caller
        token.mint(msg.sender, amountToMint);
        
        // Transfer fee to owner
        owner.transfer(fee);
        
        emit InscriptionCreated(address(token), symbol, totalSupply, perMint, price);
    }
}

contract ERC20Inscription is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) private _balances;
    
    constructor(string memory _symbol, uint _totalSupply, uint _perMint) {
        name = "Inscription Token";
        symbol = _symbol;
        totalSupply = _totalSupply * (10 ** uint256(decimals));
        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function mint(address recipient, uint amount) external {
        require(amount <= totalSupply, "Exceeds total supply");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(amount <= _balances[msg.sender], "Insufficient balance");
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount <= _balances[sender], "Transfer amount exceeds balance");
        
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
}
