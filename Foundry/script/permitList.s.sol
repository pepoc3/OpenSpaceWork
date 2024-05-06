// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarketV1} from "../src/permitList/NFTMarketV1.sol";
import {NFTMarketV2} from "../src/permitList/NFTMarketV2.sol";
import {ERC721} from "../src/permitList/NFT.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
contract permitListScript is Script {
    // NftMarket mkt;
    ERC721 nft;
    ERC20 token;
    event BalancePrinted(uint256 balance);
    address alice = 0x23AE1FC8E4e40274BeB45bb63f773C902EDD7423;

   

    


    function setUp() public {
    //Deploy a UUPS proxy
    address proxy = Upgrades.deployUUPSProxy(
    "NFTMarketV1.sol",
    abi.encodeCall(NFTMarketV1.initialize, (address(nft), address(token)))
    );
    //初始化NFTMarketV1
    NFTMarketV1 mktV1 = NFTMarketV1(proxy);

    // 升级合约
    Upgrades.upgradeProxy (
    proxy,
    "NFTMarketV2.sol",
    abi.encodeCall(NFTMarketV2.initialize, address(nft), address(token))
    );
    }
    function run() public {
        vm.startBroadcast();
        nft = new ERC721("S2NFT","S2");
        token = new ERC20();
        
        console.log("token:", address(token));
        console.log("mkt:", address(mkt));
        console.log("nft:", address(nft));
        token.transfer(alice, 1);
        nft.mint(alice, 1);

        emit BalancePrinted(token.balanceOf(alice));
        require(token.balanceOf(alice)==100000000000000000000000000, "bad amount");
    }
}
