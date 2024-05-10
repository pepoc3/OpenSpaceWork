// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "forge-std/Test.sol";
import {RNTStake} from "../src/RNTStake.sol";
import {ESRNT} from "../src/ESRNT.sol";
import {RNT} from "../src/RNT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract RNTStakeTest is Test {
   RNT rnt;
   ESRNT esRNT;
   RNTStake rntStake;
   address bob;
    function setUp() public {
        bob = makeAddr("bob"); 
        rnt = new RNT();
        esRNT = new ESRNT(rnt);
        rntStake = new RNTStake(rnt, esRNT);
    }

    function test_stake() public{
        userStake(1);
        // console.log(rnt.balanceOf(address(rnt)));
    }
    function userStake(uint256 stakeAmount) public {
        vm.prank(address(this));
        rnt.transfer(bob, 100);
        vm.prank(bob);
        rnt.approve(address(rntStake),1);
        vm.prank(bob);
        rntStake.stake(stakeAmount);
    }
    function test_unstake() public {
        userStake(1);
        vm.prank(bob);
        rntStake.unstake(1);
    }

    function test_claim() public {
        userStake(1);
        vm.warp(1 days);
        vm.prank(address(rntStake));
        rnt.approve(address(esRNT), 9999884259259195260);
        vm.prank(bob);
        rntStake.claim();
    }
}