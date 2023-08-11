// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2, stdJson} from "forge-std/Script.sol";
import {OmniPayCore} from "../src/OmniPayCore.sol";
import {OmniPayClient} from "../src/OmniPayClient.sol";
import {ExternalRouter} from "../src/router/ExternalRouter.sol";
import {FakeUSDC} from "../src/util/FakeUSDC.sol";
import {ILayerZeroEndpoint} from "LayerZero/interfaces/ILayerZeroEndpoint.sol";
import {MultiRpcScript} from "./helpers/MultiRpcScript.sol";
import {ContractConstants, JsonReader, JsonWriter} from "./helpers/ContractHelpers.sol";

contract Deploy is MultiRpcScript, ContractConstants, JsonWriter {
    using stdJson for string;

    function run() public cleanup {
        // select Optimism fork
        selectOptimismFork();

        // create USDC
        FakeUSDC optimismUsdc = new FakeUSDC();
        contracts.optimismUsdc = address(optimismUsdc);
        console2.log("FakeUSDC - Optimism: ", contracts.optimismUsdc);
        optimismUsdc.mint(_deployer, 1_000_000_000e18);

        // create OmniPayCore
        OmniPayCore omniPayCore = new OmniPayCore( contracts.optimismUsdc, optimismEndpoint);
        contracts.omniPayCore = address(omniPayCore);
        console2.log("OmniPayCore: ", contracts.omniPayCore);
        optimismUsdc.mint(contracts.omniPayCore, 1_000_000_000e18);
        optimismUsdc.approve(contracts.omniPayCore, type(uint256).max);

        // create ExternalRouter
        ExternalRouter optimismExternalRouter = new ExternalRouter(contracts.omniPayCore, optimismChainId);
        contracts.optimismExternalRouter = address(optimismExternalRouter);
        console2.log("ExternalRouter - Optimism: ", contracts.optimismExternalRouter);
        omniPayCore.setExternalRouter(contracts.optimismExternalRouter);

        // select Base fork
        selectBaseFork();

        // create USDC
        FakeUSDC baseUsdc = new FakeUSDC();
        contracts.baseUsdc = address(baseUsdc);
        console2.log("FakeUSDC - Base: ", contracts.baseUsdc);
        baseUsdc.mint(_deployer, 1_000_000_000e18);

        // create OmniPayClient
        OmniPayClient baseOmniPayClient =
            new OmniPayClient(contracts.baseUsdc, baseEndpoint, contracts.omniPayCore, optimismChainId);
        contracts.baseOmniPay = address(baseOmniPayClient);
        console2.log("OmniPayClient - Base: ", contracts.baseOmniPay);
        baseUsdc.mint(contracts.baseOmniPay, 1_000_000_000e18);
        baseUsdc.approve(contracts.baseOmniPay, type(uint256).max);

        // select Zora fork
        selectZoraFork();

        // create USDC
        FakeUSDC zoraUsdc = new FakeUSDC();
        contracts.zoraUsdc = address(zoraUsdc);
        console2.log("FakeUSDC - Zora: ", contracts.zoraUsdc);
        zoraUsdc.mint(_deployer, 1_000_000_000e18);

        // create OmniPayClient
        OmniPayClient zoraOmniPayClient =
            new OmniPayClient(contracts.zoraUsdc, address(0), contracts.omniPayCore, optimismChainId);
        contracts.zoraOmniPay = address(zoraOmniPayClient);
        console2.log("OmniPayClient - Zora: ", contracts.zoraOmniPay);
        zoraUsdc.mint(contracts.zoraOmniPay, 1_000_000_000e18);
        zoraUsdc.approve(contracts.zoraOmniPay, type(uint256).max);

        // create ExternalRouter
        ExternalRouter zoraExternalRouter = new ExternalRouter(contracts.zoraOmniPay, zoraChainId);
        contracts.zoraExternalRouter = address(zoraExternalRouter);
        console2.log("ExternalRouter - Zora: ", contracts.zoraExternalRouter);
        zoraOmniPayClient.setLayerZeroEndpoint(contracts.zoraExternalRouter);

        // select Mode fork
        selectModeFork();

        // create USDC
        FakeUSDC modeUsdc = new FakeUSDC();
        contracts.modeUsdc = address(modeUsdc);
        console2.log("FakeUSDC - Mode: ", contracts.modeUsdc);
        modeUsdc.mint(_deployer, 1_000_000_000e18);

        // create OmniPayClient
        OmniPayClient modeOmniPayClient =
            new OmniPayClient(contracts.modeUsdc, address(0), contracts.omniPayCore, optimismChainId);
        contracts.modeOmniPay = address(modeOmniPayClient);
        console2.log("OmniPayClient - Mode: ", contracts.modeOmniPay);
        modeUsdc.mint(contracts.modeOmniPay, 1_000_000_000e18);
        modeUsdc.approve(contracts.modeOmniPay, type(uint256).max);

        // create ExternalRouter
        ExternalRouter modeExternalRouter = new ExternalRouter(contracts.modeOmniPay, modeChainId);
        contracts.modeExternalRouter = address(modeExternalRouter);
        console2.log("ExternalRouter - Mode: ", contracts.modeExternalRouter);
        modeOmniPayClient.setLayerZeroEndpoint(contracts.modeExternalRouter);

        // set trusted remote lookups on Optimism
        selectOptimismFork();
        omniPayCore.setTrustedRemoteLookup(baseChainId, abi.encodePacked(contracts.baseOmniPay, contracts.omniPayCore));
        omniPayCore.setTrustedRemoteLookup(zoraChainId, abi.encodePacked(contracts.zoraOmniPay, contracts.omniPayCore));
        omniPayCore.setTrustedRemoteLookup(modeChainId, abi.encodePacked(contracts.modeOmniPay, contracts.omniPayCore));

        // fund OmniPayCore
        payable(contracts.omniPayCore).transfer(0.1 ether);

        // set trusted remote lookups on Base
        selectBaseFork();
        baseOmniPayClient.setTrustedRemoteLookup(
            optimismChainId, abi.encodePacked(contracts.omniPayCore, contracts.baseOmniPay)
        );

        // fund OmniPayClient
        payable(contracts.baseOmniPay).transfer(0.1 ether);

        // set trusted remote lookups on Zora
        selectZoraFork();
        zoraOmniPayClient.setTrustedRemoteLookup(
            optimismChainId, abi.encodePacked(contracts.omniPayCore, contracts.zoraOmniPay)
        );

        // fund OmniPayClient
        payable(contracts.zoraOmniPay).transfer(0.1 ether);

        // set trusted remote lookups on Mode
        selectModeFork();
        modeOmniPayClient.setTrustedRemoteLookup(
            optimismChainId, abi.encodePacked(contracts.omniPayCore, contracts.modeOmniPay)
        );

        // fund OmniPayClient
        payable(contracts.modeOmniPay).transfer(0.1 ether);

        writeToJson();
    }
}

contract Deposit is MultiRpcScript, JsonReader {
    function run() public cleanup {
        selectBaseFork();

        OmniPayClient baseOmniPayClient = OmniPayClient(payable(contracts.baseOmniPay));
        baseOmniPayClient.deposit(10e18);
    }
}

contract Withdraw is MultiRpcScript, JsonReader {
    function run() public cleanup {
        selectBaseFork();

        OmniPayClient baseOmniPayClient = OmniPayClient(payable(contracts.baseOmniPay));
        baseOmniPayClient.withdraw(10e18);
    }
}

contract CheckBalance is MultiRpcScript, JsonReader {
    function run() public cleanup {
        selectOptimismFork();

        OmniPayCore omniPayCore = OmniPayCore(payable(contracts.omniPayCore));
        console2.log("Deployer address: ", _deployer);
        console2.log("Current deployer USDC balance: ", omniPayCore.balances(_deployer));
    }
}

contract WithdrawEthFromAll is MultiRpcScript, JsonReader {
    function run() public cleanup {
        selectOptimismFork();

        OmniPayCore omniPayCore = OmniPayCore(payable(contracts.omniPayCore));
        omniPayCore.withdrawEth();

        selectBaseFork();
        OmniPayClient baseOmniPayClient = OmniPayClient(payable(contracts.baseOmniPay));
        baseOmniPayClient.withdrawEth();

        selectZoraFork();
        OmniPayClient zoraOmniPayClient = OmniPayClient(payable(contracts.zoraOmniPay));
        zoraOmniPayClient.withdrawEth();

        selectModeFork();
        OmniPayClient modeOmniPayClient = OmniPayClient(payable(contracts.modeOmniPay));
        modeOmniPayClient.withdrawEth();
    }
}

contract Fix is MultiRpcScript, JsonReader, ContractConstants {
    function run() public cleanup {
        // set trusted remote lookups on Zora
        selectZoraFork();
        OmniPayClient(payable(contracts.zoraOmniPay)).setTrustedRemoteLookup(
            optimismChainId, abi.encodePacked(contracts.omniPayCore, contracts.zoraOmniPay)
        );

        // fund OmniPayClient
        payable(contracts.zoraOmniPay).transfer(0.1 ether);

        // set trusted remote lookups on Mode
        selectModeFork();
        OmniPayClient(payable(contracts.modeOmniPay)).setTrustedRemoteLookup(
            optimismChainId, abi.encodePacked(contracts.omniPayCore, contracts.modeOmniPay)
        );
    }
}
