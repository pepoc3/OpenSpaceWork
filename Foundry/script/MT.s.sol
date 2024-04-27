// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyToken} from "../src/NFTMarket/MyToken.sol";
contract MTScript is Script {
    MyToken mt;
    string name = "mt";
    string symbol = "mt";
    function setUp() public {}
    function run() public {
        vm.startBroadcast();
        mt = new MyToken(name,symbol);
    }
}
