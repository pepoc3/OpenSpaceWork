// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/NFTMarket/Bank.sol";

contract BankTest is Test {

    Bank bk;
    address alice = makeAddr("Alice");
    function setUp() public {
        bk = new Bank();
    }
    function testDepositETH() public {
        
        uint256 amount = 100;
        vm.prank(alice);
        bk.depositETH(alice, amount);
          // 检查事件输出是否符合预期
        
        // 检查 balanceOf 余额更新是否符合预期
        assertEq(bk.balanceOf(alice), amount, "Balance should be updated correctly");
    }
    
    
} 
