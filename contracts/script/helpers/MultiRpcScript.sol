// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

contract MultiRpcScript is Script {
    uint256 _optimismFork = vm.createFork(vm.rpcUrl("optimism"));
    uint256 _baseFork = vm.createFork(vm.rpcUrl("base"));
    uint256 _zoraFork = vm.createFork(vm.rpcUrl("zora"));
    uint256 _modeFork = vm.createFork(vm.rpcUrl("mode"));
    uint256 _deployerPrivateKey;
    address _deployer;

    modifier cleanup() {
        _;
        vm.stopBroadcast();
    }

    constructor() {
        _deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        _deployer = vm.addr(_deployerPrivateKey);
        vm.startBroadcast(_deployerPrivateKey);
    }

    function selectOptimismFork() internal {
        vm.stopBroadcast();
        vm.selectFork(_optimismFork);
        vm.startBroadcast(_deployerPrivateKey);
    }

    function selectBaseFork() internal {
        vm.stopBroadcast();
        vm.selectFork(_baseFork);
        vm.startBroadcast(_deployerPrivateKey);
    }

    function selectZoraFork() internal {
        vm.stopBroadcast();
        vm.selectFork(_zoraFork);
        vm.startBroadcast(_deployerPrivateKey);
    }

    function selectModeFork() internal {
        vm.stopBroadcast();
        vm.selectFork(_modeFork);
        vm.startBroadcast(_deployerPrivateKey);
    }
}
