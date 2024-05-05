// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;
import "../../src/EIP2612/ERC2612.sol";
import "../../src/EIP2612/TokenBank.sol";

import "forge-std/Test.sol";

contract TokenBankTest is Test {
    uint alicePrivateKey;
    uint bobPrivateKey;
    address alice;
    address bob;
    address TokenAddress;
    address TokenBankAddress;

    event Deposited(address from, address to, uint value);

    function setUp() public {
        TokenAddress = address(new ERC2612());

        TokenBankAddress = address(new TokenBank(TokenAddress));
        alicePrivateKey = 1;
        bobPrivateKey = 2;

        alice = vm.addr(alicePrivateKey);
        bob = vm.addr(bobPrivateKey);

        ERC2612(TokenAddress).transfer(alice, 1e18);
        console.log("alice", alice);
        console.log("bob", bob);
    }

    function test_permitDeposit() public {
        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                NewToken(newTokenAddress).DOMAIN_SEPARATER(),
                keccak256(
                    abi.encode(
                        keccak256(
                            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                        ),
                        alice,
                        TokenBankAddress,
                        1e18,
                        0,
                        1 days
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);

        // bob use signature to deposit successfully
        vm.prank(bob);
        vm.expectEmit();
        emit Deposited(alice, TokenBankAddress, 1e18);
        NewTokenBank(TokenBankAddress).permitDeposit(
            alice,
            1e18,
            1 days,
            v,
            r,
            s
        );
    }
}