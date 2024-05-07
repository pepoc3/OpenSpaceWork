// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "forge-std/Test.sol";
import "../../src/EIP2612/ERC2612-NFT.sol";
import "../../src/EIP2612/NFTMarket.sol";
import "../../src/EIP2612/ERC2612.sol";

contract NftMarketTest is Test {
    address nftAddress;
    address nftMarketAddress;
    address tokenAddress;
    address alice;
    uint256 aliceKey;

    function setUp() public {
        (alice, aliceKey) = makeAddrAndKey("alice");
        vm.startPrank(alice);
        nftAddress = address(new ERC2612-NFT(11155111));
        tokenAddress = address(new ERC2612());
        nftMarketAddress = address(new NFTMarket(nftAddress,tokenAddress));
        vm.stopPrank();

    }

    function test_permitBuy() public {
        address tom = makeAddr("tom");
        vm.prank(tom);
        ERC2612-Nft(nftAddress).mint();
        vm.prank(address(this));
        ERC2612(tokenAddress).transfer(tom, 100);

        NFTMarket(nftMarketAddress).list(0, 100);

        vm.startPrank(alice);
        bytes32 hash = keccak256(abi.encodePacked(tom, uint256(0)));
        hash = MessageHashUtils.toEthSignedMessageHash(hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(aliceKey, hash);
        bytes memory sig = abi.encodePacked(r, s, v);
        vm.stopPrank();

        vm.startPrank(tom);
        ERC2612(tokenAddress).approve(address(nftMarket), 100);

        nftMarket.permitBuy(0, sig, 0);

        assertEq(token.balanceOf(tom), 0);
        assertEq(nft.balanceOf(tom), 1);
    }
}