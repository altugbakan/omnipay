// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, stdJson} from "forge-std/Script.sol";

contract ContractConstants {
    uint16 internal optimismChainId = 10132;
    address internal optimismEndpoint = 0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1;
    uint16 internal baseChainId = 10160;
    address internal baseEndpoint = 0x6aB5Ae6822647046626e83ee6dB8187151E1d5ab;
    uint16 internal zoraChainId = 9999; // Doesn't actually exist
    uint16 internal modeChainId = 9998; // Doesn't actually exist
}

contract JsonReader is Script {
    using stdJson for string;

    struct Contracts {
        address omniPayCore;
        address baseOmniPay;
        address zoraOmniPay;
        address modeOmniPay;
        address optimismUsdc;
        address baseUsdc;
        address zoraUsdc;
        address modeUsdc;
        address optimismExternalRouter;
        address zoraExternalRouter;
        address modeExternalRouter;
    }

    Contracts internal contracts;

    constructor() {
        string memory json = vm.readFile("./out/contracts.json");

        contracts.omniPayCore = json.readAddress(".OmniPayCore");
        contracts.baseOmniPay = json.readAddress(".BaseOmniPayClient");
        contracts.zoraOmniPay = json.readAddress(".ZoraOmniPayClient");
        contracts.modeOmniPay = json.readAddress(".ModeOmniPayClient");
        contracts.optimismUsdc = json.readAddress(".OptimismUSDC");
        contracts.baseUsdc = json.readAddress(".BaseUSDC");
        contracts.zoraUsdc = json.readAddress(".ZoraUSDC");
        contracts.modeUsdc = json.readAddress(".ModeUSDC");
        contracts.optimismExternalRouter = json.readAddress(".OptimismExternalRouter");
        contracts.zoraExternalRouter = json.readAddress(".ZoraExternalRouter");
        contracts.modeExternalRouter = json.readAddress(".ModeExternalRouter");
    }
}

contract JsonWriter is Script, JsonReader {
    using stdJson for string;

    function writeToJson() internal {
        string memory json = "key";
        json.serialize("OmniPayCore", address(contracts.omniPayCore));
        json.serialize("BaseOmniPayClient", address(contracts.baseOmniPay));
        json.serialize("ZoraOmniPayClient", address(contracts.zoraOmniPay));
        json.serialize("ModeOmniPayClient", address(contracts.modeOmniPay));
        json.serialize("OptimismUSDC", address(contracts.optimismUsdc));
        json.serialize("BaseUSDC", address(contracts.baseUsdc));
        json.serialize("ZoraUSDC", address(contracts.zoraUsdc));
        json.serialize("ModeUSDC", address(contracts.modeUsdc));
        json.serialize("OptimismExternalRouter", address(contracts.optimismExternalRouter));
        json.serialize("ZoraExternalRouter", address(contracts.zoraExternalRouter));
        json = json.serialize("ModeExternalRouter", address(contracts.modeExternalRouter));

        vm.writeFile("./out/contracts.json", json);
    }
}
