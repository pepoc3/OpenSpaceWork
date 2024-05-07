// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarketV1} from "../src/permitList/NFTMarketV1.sol";
import {NFTMarketV2} from "../src/permitList/NFTMarketV2.sol";
import {NFT} from "../src/permitList/NFT.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Token} from "../src/permitList/Token.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Options} from "openzeppelin-foundry-upgrades/Options.sol";
contract permitListScript is Script {
    // NftMarket mkt;
    NFT nft;
    Token token;
    event BalancePrinted(uint256 balance);
    address alice = 0x23AE1FC8E4e40274BeB45bb63f773C902EDD7423;


    function setUp() public {
    
    }
    function run() public {
        vm.startBroadcast();

        Options memory opts;
        opts.unsafeSkipAllChecks =true;

        
        nft = new NFT();
        token = new Token("pepoc3","pepoc3");
        
        console.log("token:", address(token));
        // console.log("mktV1:", address(mktV1));
        // console.log("mktV2:", address(mktV2));

        console.log("nft:", address(nft));
        // vm.prank(address(this));
        // vm.prank(alice);
        token.transfer(alice, 1);
        // vm.prank(alice);

        //Deploy a UUPS proxy

        bytes memory data =abi.encodeWithSelector(NFTMarketV1.initialize.selector,address(nft), address(token));


        new NFTMarketV1();


        address proxy = Upgrades.deployUUPSProxy(
        "NFTMarketV1.sol:NFTMarketV1",data);

        console.log("proxy:",proxy);
        //初始化NFTMarketV1
        // NFTMarketV1 mktV1 = NFTMarketV1(proxy);

        // 升级合约
        // Upgrades.upgradeProxy (
        // proxy,
        // "NFTMarketV2.sol",
        // ""
        // );
        // nft.mint(alice);


        // emit BalancePrinted(token.balanceOf(alice));
        require(token.balanceOf(alice)==1, "bad amount");
    }
}
