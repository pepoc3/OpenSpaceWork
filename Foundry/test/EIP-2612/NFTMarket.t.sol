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

    function setUp() public {
        nftAddress = address(new ERC2612-NFT(11155111));
        tokenAddress = address(new ERC2612());
        nftMarketAddress = address(new NFTMarket(nftAddress,tokenAddress));
    }

    function test_permitBuy() public {
        uint alicePrivateKey = 1;
        uint tomPrivateKey = 2;
        address alice = vm.addr(alicePrivateKey);
        address tom = vm.addr(tomPrivateKey);

        vm.prank(alice);
        ERC2612-Nft(nftAddress).mint();

        ERC2612(tokenAddress).transfer(tom, 1e18);

        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                ERC2612-Nft(nftAddress).DOMAIN_SEPARATER(),
                keccak256(
                    abi.encode(
                        keccak256(
                            "Permit(address from,address to,uint256 nftId,uint256 nonce,uint256 deadline)"
                        ),
                        alice,
                        nftMarketAddress,
                        0,
                        0,
                        2 days
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);

    
        vm.prank(tom);
        NewToken(tokenAddress).approve(nftMarketAddress, 1e18);
        console.log(
            "allowance from tom to nft market",
            NewToken(tokenAddress).allowance(tom, nftMarketAddress)
        );

        vm.prank(tom);
        NftMarket(nftMarketAddress).permitBuy(
            alice,
            nftMarketAddress,
            1e18,
            0,
            0,
            2 days,
            v,
            r,
            s
        );

        vm.assertEq(NewNft(nftAddress).ownerOf(0), tom);
    }
}