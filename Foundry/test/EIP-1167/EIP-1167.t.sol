// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {CloneFactory} from "../../src/EIP-1167/EIP-1167.sol";
import {Implementation} from "../../src/EIP-1167/EIP-1167.sol";

contract ERC20FactoryTest is Test {
    Implementation bi;
    CloneFactory factory;

    uint256 ownerPrivateKey = 0xA11CE;
    address alice = vm.addr(ownerPrivateKey);
    uint256 buyerPrivateKey = 0xB22DC;

 
    function setUp() public {
        vm.startPrank(alice);
        bi = new Implementation();
        factory = new CloneFactory();
    }
    function test_deployInscription() public {
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
}