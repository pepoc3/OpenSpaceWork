// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "forge-std/Test.sol";
import "../src/permitList-2/NFT.sol";
import "../src/permitList-2/NftMarketV1.sol";
import "../src/permitList-2/NftMarketV2.sol";
import "../src/permitList-2/Token.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract NftMarketV2Test is Test {
    address nftAddress;
    address tokenAddress;
    address uupsProxy;

    address alice;
    address bob;

    event Listed(address from, uint price);

    function setUp() public {
        alice = vm.addr(1);
        bob = makeAddr("bob"); 

        nftAddress = address(new NFT());
        tokenAddress = address(new Token());
        vm.prank(alice);
        NFT(nftAddress).mint();
        Token(tokenAddress).transfer(bob, 1 ether);


        uupsProxy = Upgrades.deployUUPSProxy(
            "NftMarketV1.sol",
            abi.encodeCall(
                NftMarketV1.initialize,
                (tokenAddress, nftAddress, address(this))
            )
        );
    }

    function test_upgradeToV2() public {
        NftMarketV1 instance = NftMarketV1(uupsProxy);
        vm.prank(alice);
        NFT(nftAddress).approve(address(instance), 0);
        vm.prank(alice);
        instance.list(0, 1 ether);
        vm.prank(bob);
        Token(tokenAddress).approve(address(instance), 1 ether);
        vm.prank(bob);
        instance.buyNFT(0);

        vm.assertEq(Token(tokenAddress).balanceOf(alice), 1 ether);
        vm.assertEq(NFT(nftAddress).ownerOf(0), bob);

        Upgrades.upgradeProxy(uupsProxy, "NftMarketV2.sol", "");

        NftMarketV2 instance2 = NftMarketV2(uupsProxy);
        vm.prank(bob);
        NFT(nftAddress).approve(address(instance2), 0);
        vm.prank(bob);
        instance.list(0, 1 ether);
        vm.prank(alice);
        Token(tokenAddress).approve(address(instance2), 1 ether);
        vm.prank(alice);
        instance.buyNFT(0);

        vm.assertEq(Token(tokenAddress).balanceOf(bob), 1 ether);
        vm.assertEq(NFT(nftAddress).ownerOf(0), alice);

    }

}