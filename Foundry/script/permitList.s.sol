// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "forge-std/Script.sol";
import "../src/permitList/NFT.sol";
import "../src/permitList/Token.sol";
import "../src/permitList/NftMarketV1.sol";
import "../src/permitList/NftMarketV2.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract NewPermitListScript is Script {
    function run() public {
        vm.startBroadcast();
        address nftAddress = address(new NFT());
        address tokenAddress = address(
            new Token()
        );

        address uupsProxy = Upgrades.deployUUPSProxy(
            "NftMarketV1.sol",
            abi.encodeCall(
                NftMarketV1.initialize,
                (tokenAddress, nftAddress, 0x23AE1FC8E4e40274BeB45bb63f773C902EDD7423)
            )
        );
        // upgrade to V2
        Upgrades.upgradeProxy(uupsProxy, "NftMarketV2.sol", "");
        vm.stopBroadcast();

        console.log("UUPS Proxy Address:", address(uupsProxy));
    }
}