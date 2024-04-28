// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {Counter} from "../src/Counter.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        Counter c = new Counter();

        console.log("Counter address:", address(c));
    }
}
