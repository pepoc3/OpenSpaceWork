// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/StakingPool-new.sol";
import "../src/IToken.sol";
import "../src/IStaking.sol";
import {KK} from "../src/KK.sol";


contract StakingPoolTest is Test {
    StakingPool public stakingPool;
    KK public kkToken;
    address public user1;
    address public user2;

    function setUp() public {
        kkToken = new KK();
        stakingPool = new StakingPool(kkToken);
        kkToken.mint(address(stakingPool), 10000 ether);
        user1 = address(0x123);
        user2 = address(0x456);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    function testStake() public {
        vm.startPrank(user1);
        stakingPool.stake{value: 1 ether}();
        vm.stopPrank();

        assertEq(stakingPool.balanceOf(user1), 1 ether);
        assertEq(address(stakingPool).balance, 1 ether);
    }

    function testUnstake() public {
        vm.startPrank(user1);
        stakingPool.stake{value: 1 ether}();
        stakingPool.unstake(0.5 ether);
        vm.stopPrank();

        assertEq(stakingPool.balanceOf(user1), 0.5 ether);
        assertEq(address(stakingPool).balance, 0.5 ether);
    }

    function testClaim() public {
        vm.prank(user1);
        stakingPool.stake{value: 1 ether}();
        vm.prank(user2);
        stakingPool.stake{value: 2 ether}();
        vm.roll(block.number + 10); // 快进10个区块
        vm.prank(user1);
        stakingPool.claim();
        // vm.roll(block.number + 10); // 快进10个区块

        vm.prank(user2);
        stakingPool.claim();

        console.log(kkToken.balanceOf(user1));
        console.log(kkToken.balanceOf(user2));
        uint256 expectedRewards = 10 ether * 10;
        assertEq(kkToken.balanceOf(user1), expectedRewards*1/3);
        assertEq(kkToken.balanceOf(user2), expectedRewards*2/3);

    }

    // function testMultipleUsersStake() public {
    //     vm.startPrank(user1);
    //     stakingPool.stake{value: 1 ether}();
    //     vm.stopPrank();

    //     vm.startPrank(user2);
    //     stakingPool.stake{value: 2 ether}();
    //     vm.stopPrank();

    //     assertEq(stakingPool.balanceOf(user1), 1 ether);
    //     assertEq(stakingPool.balanceOf(user2), 2 ether);
    //     assertEq(address(stakingPool).balance, 3 ether);
    // }

    function testEarned() public {
        vm.startPrank(user1);
        stakingPool.stake{value: 1 ether}();
        vm.roll(block.number + 10); // 快进10个区块
        vm.stopPrank();

        uint256 expectedRewards = 10 ether * 10; // 每个区块产出10个KK Token
        assertEq(stakingPool.earned(user1), expectedRewards);
    }
}
