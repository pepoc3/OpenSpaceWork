// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "forge-std/Test.sol";
import "../src/permitList-2/NFT.sol";
import "../src/permitList-2/NftMarketV1.sol";
import "../src/permitList-2/NftMarketV2.sol";
import "../src/permitList-2/Token.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract NftMarketV2PermitListTest is Test {
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

        Upgrades.upgradeProxy(uupsProxy, "NftMarketV2.sol", "");
    }

    function test_permitList() public{


        uint timestamp = block.timestamp;

        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                NFT(nftAddress).DOMAIN_SEPARATER(),
                keccak256(
                    abi.encode(
                        keccak256(
                            "Permit(address from,address to,uint256 nftId,uint price,uint256 nonce,uint256 deadline)"
                        ),
                        alice,
                        uupsProxy,
                        0,
                        1e18,
                        0,
                        timestamp + 2 days
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);
        console.log("Alice generated the signature for digest");

        vm.prank(alice);
        NFT(nftAddress).setApprovalForAll(uupsProxy, true);

        vm.expectEmit();
        emit Listed(alice, 1e18);
        NftMarketV2(uupsProxy).permitList(
            alice,
            uupsProxy,
            0,
            1e18,
            0,
            timestamp + 2 days,
            v,
            r,
            s
        );
    }
}