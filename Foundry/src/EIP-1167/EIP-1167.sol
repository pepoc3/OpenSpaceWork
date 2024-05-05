// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract Implementation is ERC20{
    bool public isBase;
    address public owner;
    uint permint;
    mapping(address => uint256) private _balances;

    modifier onlyOwner() {
        require(msg.sender == owner, "Error:Only Owner");
        _;
    }
    constructor() ERC20("IF", "IF") {
        
        isBase = true;
    }

    function initialize(
        address _owner,
        string calldata _name,
        string calldata _symbol,
        uint _totalSupply,
        uint _permint,
        uint price) external {
        require(isBase == false, "Error: This base contract, cannot initialize");
        require(owner == address(0), "Error: Contract already initialized");
        owner = _owner;
        permint = _permint;
        _totalSupply = _totalSupply;
        _name = _name;
        _symbol = _symbol;
    }
     function mint(address user, uint fee) external payable onlyOwner{
        _mint(user, permint);
        payable(owner).transfer(msg.value-fee); // Transfer the minting fee to the contract owner

    }
    
    
}

interface implementation {
    function initialize( 
        address,
        string calldata,
        string calldata,
        uint,
        uint) external;
}

contract CloneFactory {
    address public implement;
    mapping(address => address[]) allClones;
    event NewClone(address _newClone, address _owner);
    uint price;
    uint feePercent = 10;
    uint fee = price * feePercent / 100 ;
    constructor(address _implement) {
        implement = _implement;
        
    }

    function deployInscription(
        string calldata _name,
        string calldata _symbol,
        uint _totalSupply,
        uint _permint,
        uint setprice) external {
        address child = Clones.clone(implement);
        allClones[msg.sender].push(child);
        price = setprice;
        Implementation(child).initialize(
            msg.sender,
            _name,
            _symbol,
            _totalSupply,
            _permint,
            price
        );
    
    }

    function mintInscription(address tokenAddr) payable external {
    // require(msg.value >= price, "Insufficient funds");
    Implementation(tokenAddr).mint(msg.sender, fee);
    }
}