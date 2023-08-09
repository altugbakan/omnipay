// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console2} from "forge-std/Script.sol";
import {MultiRpcScript} from "./helpers/MultiRpcScript.sol";
import {ContractConstants, JsonReader, JsonWriter} from "./helpers/ContractHelpers.sol";
import {ExternalRouter} from "../src/router/ExternalRouter.sol";
import {OmniPayCore} from "../src/OmniPayCore.sol";
import {OmniPayClient} from "../src/OmniPayClient.sol";

contract Deploy is MultiRpcScript, ContractConstants, JsonWriter {
    function run() public cleanup {
        selectOptimismFork();

        ExternalRouter optimismExternalRouter = new ExternalRouter(contracts.omniPayCore, optimismChainId);
        contracts.optimismExternalRouter = address(optimismExternalRouter);
        console2.log("ExternalRouter - Optimism: ", contracts.optimismExternalRouter);
        OmniPayCore omniPayCore = OmniPayCore(payable(contracts.omniPayCore));
        omniPayCore.setExternalRouter(contracts.optimismExternalRouter);

        selectZoraFork();

        ExternalRouter zoraExternalRouter = new ExternalRouter(contracts.zoraOmniPay, zoraChainId);
        contracts.zoraExternalRouter = address(zoraExternalRouter);
        console2.log("ExternalRouter - Zora: ", contracts.zoraExternalRouter);
        OmniPayClient(payable(contracts.zoraOmniPay)).setLayerZeroEndpoint(contracts.zoraExternalRouter);

        selectModeFork();
        ExternalRouter modeExternalRouter = new ExternalRouter(contracts.modeOmniPay, modeChainId);
        contracts.modeExternalRouter = address(modeExternalRouter);
        console2.log("ExternalRouter - Mode: ", contracts.modeExternalRouter);
        OmniPayClient(payable(contracts.modeOmniPay)).setLayerZeroEndpoint(contracts.modeExternalRouter);

        writeToJson();
    }
}

contract DepositZora is MultiRpcScript, JsonReader {
    function run() public cleanup {
        selectZoraFork();

        OmniPayClient(payable(contracts.zoraOmniPay)).deposit(10e18);
    }
}

contract WithdrawZora is MultiRpcScript, JsonReader {
    function run() public cleanup {
        selectZoraFork();

        OmniPayClient(payable(contracts.zoraOmniPay)).withdraw(10e18);
    }
}

contract DepositMode is MultiRpcScript, JsonReader {
    function run() public cleanup {
        selectModeFork();

        OmniPayClient(payable(contracts.modeOmniPay)).deposit(10e18);
    }
}

contract WithdrawMode is MultiRpcScript, JsonReader {
    function run() public cleanup {
        selectModeFork();

        OmniPayClient(payable(contracts.modeOmniPay)).withdraw(10e18);
    }
}
