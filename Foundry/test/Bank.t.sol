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
    event Deposit(address indexed user, uint amount);
    function testDepositETH() public {
        deal(alice, 1 ether);
        // 检查事件输出是否符合预期
        vm.prank(alice);
        vm.expectEmit();
        emit Deposit(alice, 1 ether);
        bk.depositETH{value: 1 ether}();
        // 检查 balanceOf 余额更新是否符合预期
        assertEq(bk.balanceOf(alice), 1 ether, "Balance should be updated correctly");
    }
    //测试require(amount > 0, "Deposit amount must be greater than 0");
    function testDepositETH_Require() public {
        vm.prank(alice);
        vm.expectRevert("Deposit amount must be greater than 0");
        bk.depositETH{value: 0}();
    }
    
    
} 
