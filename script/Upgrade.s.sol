// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/DexAggregator.sol";

interface IProxy {
    function upgradeTo(address newImplementation) external;
}

contract Upgrade is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address proxyAddr = vm.envAddress("PROXY");

        vm.startBroadcast(pk);

        // 1. Deploy new implementation
        DexAggregator newImpl = new DexAggregator();

        // 2. Upgrade proxy
        IProxy(proxyAddr).upgradeTo(address(newImpl));

        console.log("=== UPGRADED ===");
        console.log("New Implementation:", address(newImpl));

        vm.stopBroadcast();
    }
}