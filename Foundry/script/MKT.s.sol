// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarket} from "../src/NFTMarket/NFTMarket.sol";
import {ERC721Mock} from "../test/mocks/ERC721Mock.sol";
import {ERC20} from "../src/NFTMarket/ERC20.sol";
contract MKTScript is Script {
    NFTMarket mkt;
    ERC721Mock nft;
    ERC20 token;
    address alice = 0x23AE1FC8E4e40274BeB45bb63f773C902EDD7423;
    function setUp() public {}
    event BalancePrinted(uint256 balance);
    function run() public {
        vm.startBroadcast();
        nft = new ERC721Mock("S2NFT","S2");
        token = new ERC20();
        mkt = new NFTMarket(address(nft), address(token)); 
        
        console.log("token:", address(token));
        console.log("mkt:", address(mkt));
        console.log("nft:", address(nft));
        token.transfer(alice, 1);
        nft.mint(alice, 1);

        emit BalancePrinted(token.balanceOf(alice));
        require(token.balanceOf(alice)==100000000000000000000000000, "bad amount");
    }
}
