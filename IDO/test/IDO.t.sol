// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "forge-std/Test.sol";
import {RNTStake} from "../src/RNTStake.sol";
import {ESRNT} from "../src/ESRNT.sol";
import {RNT} from "../src/RNT.sol";
import {RNTIDO} from "../src/RNTIDO.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract RNTStakeTest is Test {
   RNT rnt;
   ESRNT esRNT;
   RNTStake rntStake;
   RNTIDO IDO;
   address bob;
   address alice;
    function setUp() public {
        bob = makeAddr("bob");   //用户
        alice  = makeAddr("alice"); //项目方
        rnt = new RNT();
        esRNT = new ESRNT(rnt);
        IDO = new RNTIDO(rnt);
        vm.prank(address(this));
        rnt.transfer(address(IDO),21_000_000 * 1e18);
        vm.deal(bob, 100 ether);
    }

    function test_presale() public payable{
        
        vm.prank(bob);
        IDO.presale{value: 0.01 ether}(100);
        assertEq(IDO.balances(bob), 100, "balance is false");
    }
    
    function test_IDOClaim() public payable {
        vm.prank(bob);
        IDO.presale{value: 10 ether}(100000);
        vm.warp(10 days);
        vm.prank(bob);
        IDO.claim();
        assertEq(rnt.balanceOf(bob), 100000, "balance is false");
        
    }

    function test_refund() public payable{
        vm.prank(bob);
        IDO.presale{value: 1 ether}(10000);
        vm.warp(10 days);
        vm.prank(bob);
        IDO.refund();
        assertEq(payable(bob).balance, 100 ether, "balance is false");
    }

    function test_withdraw() public payable{
        vm.prank(bob);
        IDO.presale{value: 10 ether}(100000);
        vm.warp(10 days);
        vm.prank(alice);
        IDO.withdraw();
        assertEq(payable(alice).balance, 10 ether, "balance is false");
    }
}