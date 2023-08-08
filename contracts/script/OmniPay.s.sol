// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {OmniPayCore} from "../src/OmniPayCore.sol";
import {OmniPayClient} from "../src/OmniPayClient.sol";
import {ExternalRouter} from "../src/router/ExternalRouter.sol";
import {FakeUSDC} from "../src/util/FakeUSDC.sol";

contract OmniPayScript is Script {
    uint16 public optimismChainId = 10132;
    address public optimismEndpoint = 0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1;
    uint16 public baseChainId = 10160;
    address public baseEndpoint = 0x6aB5Ae6822647046626e83ee6dB8187151E1d5ab;
    uint16 public zoraChainId = 9999; // Doesn't exist
    ExternalRouter public zoraEndpoint;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // create and select for optimism
        vm.createSelectFork(vm.rpcUrl("optimism"));

        // create USDC
        FakeUSDC optimismUsdc = new FakeUSDC();
        console2.log("FakeUSDC - Optimism: ", address(optimismUsdc));

        // create OmniPayCore
        OmniPayCore omniPayCore = new OmniPayCore(address(optimismUsdc), optimismEndpoint);
        console2.log("OmniPayCore: ", address(omniPayCore));
        optimismUsdc.mint(address(omniPayCore), 1_000_000_000e18);

        // create ExternalRouter
        ExternalRouter optimismExternalRouter = new ExternalRouter(address(omniPayCore), optimismChainId);
        console2.log("ExternalRouter - Optimism: ", address(optimismExternalRouter));
        omniPayCore.setExternalRouter(address(optimismExternalRouter));

        // create and select for base
        vm.createSelectFork(vm.rpcUrl("base"));

        // create USDC
        FakeUSDC baseUsdc = new FakeUSDC();
        console2.log("FakeUSDC - Base: ", address(baseUsdc));

        // create OmniPayClient
        OmniPayClient baseOmniPayClient =
            new OmniPayClient(address(baseUsdc), baseEndpoint, address(omniPayCore), optimismChainId);
        console2.log("OmniPayClient - Base: ", address(baseOmniPayClient));
        baseUsdc.mint(address(baseOmniPayClient), 1_000_000_000e18);

        // create and select for zora
        vm.createSelectFork(vm.rpcUrl("zora"));

        // create USDC
        FakeUSDC zoraUsdc = new FakeUSDC();
        console2.log("FakeUSDC - Zora: ", address(zoraUsdc));

        // create OmniPayClient
        OmniPayClient zoraOmniPayClient =
            new OmniPayClient(address(zoraUsdc), address(0), address(omniPayCore), optimismChainId);
        console2.log("OmniPayClient - Zora: ", address(zoraOmniPayClient));
        zoraUsdc.mint(address(zoraOmniPayClient), 1_000_000_000e18);

        // create ExternalRouter
        zoraEndpoint = new ExternalRouter(address(zoraOmniPayClient), zoraChainId);
        console2.log("ExternalRouter - Zora: ", address(zoraEndpoint));
        zoraOmniPayClient.setLayerZeroEndpoint(address(zoraEndpoint));

        // set trusted remote lookups on Optimism
        vm.createSelectFork(vm.rpcUrl("optimism"));
        omniPayCore.setTrustedRemoteLookup(
            baseChainId, abi.encodePacked(address(baseOmniPayClient), address(omniPayCore))
        );
        omniPayCore.setTrustedRemoteLookup(
            zoraChainId, abi.encodePacked(address(zoraOmniPayClient), address(omniPayCore))
        );

        // set trusted remote lookups on Base
        vm.createSelectFork(vm.rpcUrl("base"));
        baseOmniPayClient.setTrustedRemoteLookup(
            optimismChainId, abi.encodePacked(address(omniPayCore), address(baseOmniPayClient))
        );

        // set trusted remote lookups on Zora
        vm.createSelectFork(vm.rpcUrl("zora"));
        zoraOmniPayClient.setTrustedRemoteLookup(
            optimismChainId, abi.encodePacked(address(omniPayCore), address(zoraOmniPayClient))
        );

        vm.stopBroadcast();
    }
}
