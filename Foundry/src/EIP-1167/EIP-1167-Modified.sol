// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/proxy/Clones.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ERC20} from "./ERC20.sol";



 struct Inscription {
    string symbol;
    uint256 totalSupply;
    uint256 minted;
    uint256 price;
    uint256 perMint;
    address owner;
    address token;
}

contract ERC20CloneFactory{

    ERC20 public erc20;

    mapping(address => Inscription) public inscriptions; // erc20 address => Inscription

    address payable public admin;

    uint8 fee;  //percentage of mintfee to admin

    using Address for address payable;

    event Clone(address indexed sender, address token);

    event Mint(address indexed token, address indexed sender);

    constructor(uint8 _fee) {
        erc20 = new ERC20();
        admin = payable(msg.sender);
        require(fee < 100, "fee big than 100");
        fee = _fee;
    }

    function deployInscription(string calldata symbol, uint256 totalSupply, uint256 perMint, uint256 price) public returns (address token){
        ERC20 copy = ERC20(Clones.clone(address(erc20)));
        copy.initialize(address(this), symbol, totalSupply);
        emit Clone(msg.sender, address(copy));

        Inscription memory inscription = Inscription({
            symbol: symbol,
            totalSupply: totalSupply,
            minted: 0,
            price: price,
            perMint:perMint,
            owner: msg.sender,
            token: address(copy)
        });
        inscriptions[address(copy)] = inscription;
        return address(copy);
    }

   
    function mintInscription(address tokenAddr) public payable {
        Inscription storage inscription = inscriptions[tokenAddr];
        require(inscription.token != address(0),"not exist tokenAddr");
        require(inscription.minted + inscription.perMint <= inscription.totalSupply, "mint end");
        require(msg.value >= inscription.price, "price too low");

        ERC20 token = ERC20(inscription.token);
        token.transfer(msg.sender, inscription.perMint);
        inscription.minted += inscription.perMint;

        payable(inscription.owner).sendValue(msg.value * (100 - fee) / 100);
        admin.sendValue(msg.value * fee / 100);

        emit Mint(tokenAddr, msg.sender);
    }

    function getInscription(address _erc20) view public returns (Inscription memory inscription){
        return inscriptions[_erc20];
    }
}