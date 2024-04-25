// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TokenBank} from "../src/NFTMarket/TokenBank.sol";
import {ERC20} from "../src/NFTMarket/ERC20.sol";
contract TokenHookTest is Test {

    TokenBank tb;
    ERC20 token;
    address alice = makeAddr("Alice");
    address peter = makeAddr("Peter");
    function setUp() public {
        token = new ERC20();
        tb = new TokenBank(address(token)); 
    }
    function testFailed_transferWithCallback_Amount() public {
        vm.prank(alice);
        token.transferWithCallback(address(tb), 1);
    }
    //测试require(msg.sender == address(erc20), "tokensReceived function should be called by ERC20 contract!");
    function testFailed_tokensReceived() public {
        vm.prank(alice);
        tb.tokensReceived(alice, 1);
    }
    function test_transferWithCallback() public {
        vm.prank(address(this));
        token.transfer(alice, 1);
        vm.startPrank(alice);
        token.transferWithCallback(address(tb), 1);
        assertEq(tb.balanceOf(alice), 1, "deposit from erc20 to tokenbank");
    }
    
    
} 
