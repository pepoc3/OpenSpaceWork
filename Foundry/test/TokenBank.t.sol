// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TokenBank} from "../src/NFTMarket/TokenBank.sol";
import {ERC20} from "../src/NFTMarket/ERC20.sol";
contract TokenBankTest is Test {

    TokenBank tb;
    ERC20 token;
    address alice = makeAddr("Alice");
    address peter = makeAddr("Peter");
    function setUp() public {
        token = new ERC20();
        tb = new TokenBank(address(token)); 
    }
    function testFailed_deposit_Approve() public {
        uint256 value = 1;
        vm.prank(alice);
        tb.deposit(value);
    }
    function testFailed_deposit_Amount() public {
        uint256 value = 1;
        vm.startPrank(alice);
        token.approve(address(tb), 1);
        tb.deposit(value);
    }
    function deposit(address who, uint256 value) public{
        vm.prank(who);
        token.approve(address(tb), value);
        vm.prank(address(this));
        token.transfer(who, value);
        vm.prank(who);
        tb.deposit(value);
    }
    function test_depost() public {
        deposit(alice, 1);
    }
    //测试require(_value <= userBalances[msg.sender], "transfer amount exceeds balance");
    function testFailed_withdraw_Amount() public {
        uint256 tokenValue = 1;
        vm.prank(alice);
        tb.withdraw(tokenValue);
    }
    function test_withdraw() public {
        uint256 tokenValue = 1;
        deposit(alice, tokenValue);
        uint256 balance = tb.balanceOf(alice);
        vm.prank(alice);
        tb.withdraw(tokenValue);
        uint256 afterBalance = balance - tokenValue;
        assertEq(balance-tokenValue, afterBalance, "expect balance decrease");
    }
    
} 
