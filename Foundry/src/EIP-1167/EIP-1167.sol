// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract Implementation is ERC20{
    bool public isBase;
    address public owner;
    uint _price;
    uint _totalSupply;
    uint _permint;
    uint feePercent = 10;
    uint fee;
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
        uint totalSupply,
        uint permint,
        uint price) external {
        require(isBase == false, "Error: This base contract, cannot initialize");
        require(owner == address(0), "Error: Contract already initialized");
        owner = _owner;
        _permint = permint;
        _totalSupply = totalSupply;
        _name = _name;
        _symbol = _symbol;
        _price = price;
        fee = _price * feePercent / 100 ;

    }
     function mint(address user) external payable{
        require(msg.value >= _price, "no sufficient transfer value");
         require(
            _totalSupply < _totalSupply - _permint,
            "exceed maximum supply"
        );
        _mint(user, _permint);
        payable(owner).transfer(fee); // Transfer the minting fee to the contract owner

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
    //铸造并转账
    require(
            msg.value >= price,
            "insufficient payment"
        );
    Implementation(tokenAddr).mint{value: price}(msg.sender);
    }

}