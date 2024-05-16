// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUniswapV2Factory} from "v2-core/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "v2-core/interfaces/IUniswapV2Pair.sol";
import {WETH} from "../src/WETH.sol";
import {RNT} from "../src/RNT.sol";
import {DEX} from "../src/DEX.sol";
import {Test, console} from "forge-std/Test.sol";

contract UniswapTest is Test {
    IUniswapV2Factory public factory;   //address:0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    IUniswapV2Router02 public router; //address:0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    WETH public weth;  //address:0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    RNT public rnt; 
    DEX public dex;
    IUniswapV2Pair public  pair;
    address pairaddress;
    address alice = makeAddr("Alice");  //用户
    address bob = makeAddr("Bob"); //手续费收款人(项目方)
    uint constant DEADLINE = 7 days; // 设置默认截止时间为7天
    function setUp() public {
        
        factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
        // weth = WETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        weth = new WETH();
        rnt = new RNT();
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        pairaddress = factory.createPair(address(rnt), address(weth));   //0xce9Cf1221e1891a07a92B72a6cb393a6C2F741a8

        pair = IUniswapV2Pair(pairaddress);
        dex = new DEX(address(factory), address(weth), pairaddress);
        vm.prank(address(this));
        rnt.transfer(bob, 3000 * 10e18);

        vm.prank(address(this));
        weth.transfer(bob, 3000 * 10e18);
        vm.prank(bob);
        weth.approve(address(router), 2000*10e18);
        vm.prank(bob);
        rnt.approve(address(router), 2000*10e18);
        vm.prank(bob);
        router.addLiquidity(address(rnt),address(weth), 2000*10e18, 10*10e18, 1000*10e18, 5*10e18, pairaddress, block.timestamp+DEADLINE);
    }

    function test_sellETH() public {
        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(rnt);
        vm.prank(address(this));
        weth.transfer(alice, 3000 * 10e18);
        uint256 sellAmount = 10*10e18;
        uint[] memory amountOut = router.getAmountsOut(sellAmount, path);
        uint256 minBuyAmount  = amountOut[1] * 95 / 100 ; //限制滑点
        // WETH  ->  RNT
        vm.prank(alice);
        weth.approve(address(dex), sellAmount);
        vm.prank(alice);
        dex.sellETH(sellAmount, address(rnt), minBuyAmount);
        require(rnt.balanceOf(alice) >= minBuyAmount, "alice rnt balance not enoungh");
        console.log(weth.balanceOf(alice));
        console.log(minBuyAmount);
    }

     function test_buyETH() public {
        address[] memory path = new address[](2);
        path[0] = address(rnt);
        path[1] = address(weth);
        vm.prank(address(this));
        rnt.transfer(alice, 300000000000000 * 10e18);
        uint256 sellAmount = 1000*10e18;
        uint[] memory amountOut = router.getAmountsOut(sellAmount, path);
        uint256 minBuyAmount  = amountOut[1] * 95 / 100 ; //限制滑点
        vm.prank(alice);
        rnt.approve(address(dex), sellAmount);
        // RNT  ->  WETH
        vm.prank(alice);
        dex.buyETH(address(rnt), sellAmount, minBuyAmount);
        require(weth.balanceOf(alice) >= minBuyAmount, "alice rnt balance not enoungh");
        console.log(rnt.balanceOf(alice));
        console.log(minBuyAmount);
     }


    
}

