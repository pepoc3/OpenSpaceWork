// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NFTMarket} from "../src/NFTMarket/NFTMarket.sol";
import {ERC721Mock} from "./mocks/ERC721Mock.sol";
import {ERC20} from "../src/NFTMarket/ERC20.sol";
contract NFTMarketTest is Test {

    NFTMarket mkt;
    ERC721Mock nft;
    ERC20 token;
    address alice = makeAddr("Alice");
    address peter = makeAddr("Peter");
    function setUp() public {
        
        nft = new ERC721Mock("S2NFT","S2");
        token = new ERC20();
        mkt = new NFTMarket(address(nft), address(token)); 
        vm.prank(alice);
        nft.mint(alice,1); //这行将以alice的身份执行
    }
    //测试require(nftContract.ownerOf(_tokenId) == msg.sender, "You are not the owner of this NFT");
    function testFailed_list_Ownerof() public {
        uint256 tokenId = 1;
        vm.prank(peter);
        mkt.list(tokenId, 1);

    }
    //测试require(_price > 0, "Price must be greater than zero");
    function testFailed_list_Price() public {
        uint256 tokenId = 5;
        vm.prank(alice);
        mkt.list(tokenId, 0);
    }
    function test_list() public {
        uint256 tokenId = 5;
        vm.prank(alice);
        mkt.list(tokenId, 1);
        // assertEq(mkt.queryOwner(address(nft), tokenId),)
    }
    function listNFT(uint256 tokenId, address who, uint256 price) public {
        vm.prank(who);
        mkt.list(tokenId, price);
    }
    /// forge-config: default.fuzz.runs = 500
    function test_listNFTPrice_Random(uint256 price) public {
        vm.assume(price > 1e18);
        listNFT(1, alice, price);
    }
    //测试require(listing.seller != address(0), "NFT is not listed for sale");
    function testFailed_buyNFT_Seller() public {
        vm.prank(alice);
        mkt.buyNFT(7);
    }
    //测试require(tokenContract.transferFrom(msg.sender, seller, price), "Token transfer failed");
    function testFailed_buyNFT_tokenApprove() public {
        uint256 tokenId = 1;
        vm.prank(alice);
        mkt.list(tokenId, 1);
        vm.prank(address(this));
        token.transfer(peter, 1);

        mkt.buyNFT(1);
    }
    function testFailed_buyNFT_tokenAmount() public {
        uint256 tokenId = 1;
        vm.prank(alice);
        mkt.list(tokenId, 1);
        vm.prank(peter);
        token.approve(address(mkt), 1);
        vm.prank(peter);
        mkt.buyNFT(1);
    }
    //测试nftContract.safeTransferFrom(seller, msg.sender, _tokenId);
    function testFailed_buyNFT_nftApprove() public {
        uint256 tokenId = 1;
        vm.prank(alice);
        mkt.list(tokenId, 1);
        vm.prank(address(this));
        token.transfer(peter, 1);
        vm.prank(peter);
        token.approve(address(mkt), 1);
        vm.prank(peter);
        mkt.buyNFT(1);
    }
    function test_buyNFT() public {
        uint256 tokenId = 1;
        uint256 balance = token.balanceOf(alice);
        uint256 price = 1;
        vm.prank(alice);
        mkt.list(tokenId, 1);
        vm.prank(address(this));
        token.transfer(peter, 1);
        vm.prank(peter);
        token.approve(address(mkt), 1);
        vm.prank(alice);
        nft.approve(address(mkt), 1);
        vm.prank(peter);
        mkt.buyNFT(1);
        uint256 afterBalance = token.balanceOf(alice); 
        assertEq(balance+price, afterBalance, "expect seller balance increase");
        assertEq(nft.ownerOf(tokenId), peter, "expect nft owner is buyer");

    }
    
   
} 
