// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {CloneFactory} from "../../src/EIP-1167/EIP-1167.sol";
import {Implementation} from "../../src/EIP-1167/EIP-1167.sol";

contract ERC20FactoryTest is Test {
    Implementation bi;
    CloneFactory factory;

    // uint256 ownerPrivateKey = 0xA11CE;
    // address alice = vm.addr(ownerPrivateKey);
    // uint256 buyerPrivateKey = 0xB22DC;
    address alice;
    // address bob;
 
    function setUp() public {
        vm.prank(alice);
        bi = new Implementation();
        factory = new CloneFactory(bi);
    }
    function test_deployInscription() public {
        vm.prank(alice);
        deployInscription();
    }
    function deployInscription() private {
        string memory name = "pepoc3";
        string memory symbol = "pepoc3";
        uint totalSupply = 1000;
        uint perMint = 100;
        uint price = 1000;
        factory.deployInscription(name, symbol, totalSupply, perMint, price);
    }

    function test_shouldMintAsPerMint() public {
        vm.deal(alice, 1000);
        address aliceInscription = CloneFactory(factory).allClones(alice, 0);
        vm.startPrank(alice);
        CloneFactory(factory).mintInscription{
            value: 1000
        }(aliceInscription);
        vm.assertEq(
            Inscription(aliceInscription).totalSupply(),
            1000
        );
    }

    function testFailed_mintMoreThan_totalSupplyLimit() public {
        vm.deal(alice, 1000);
        address aliceInscription = CloneFactory(factory)
            .allClones(alice, 0);
        vm.startPrank(alice);
        for (uint i = 0; i < 10; i++) {
            CloneFactory(factory).mintInscription{
                value: 1000
            }(aliceInscription);
        
        }
         CloneFactory(factory).mintInscription{
                value: 1000
            }(aliceInscription);
    }
    }

     function test_shouldSplitFee() public {
        vm.deal(alice, 1000);
        address aliceInscription = CloneFactory(factory).allClones(alice, 0);
        vm.startPrank(alice);
        CloneFactory(factory).mintInscription{
            value: 1000
        }(aliceInscription);
        vm.assertEq(aliceInscription.balance, 900);
        vm.assertEq(alice.balance, 100);
     }
}