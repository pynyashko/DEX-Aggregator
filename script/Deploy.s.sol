// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import "../src/DEXAggregator.sol";
import "../src/adapters/V2Adapter.sol";
import "../src/adapters/V3Adapter.sol";

import "./Config.s.sol";

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);

        // 1. Deploy adapters
        V2Adapter v2 = new V2Adapter(Config.V2_ROUTER);
        V3Adapter v3 = new V3Adapter(Config.V3_ROUTER, Config.V3_QUOTER);

        // 2. Deploy implementation
        DexAggregator impl = new DexAggregator();

        // 3. Encode initializer
        bytes memory data = abi.encodeCall(DexAggregator.initialize, (address(v2), address(v3)));

        // 4. Deploy proxy
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), data);

        console.log("=== DEPLOYED ===");
        console.log("V2 Adapter:", address(v2));
        console.log("V3 Adapter:", address(v3));
        console.log("Implementation:", address(impl));
        console.log("Proxy:", address(proxy));

        vm.stopBroadcast();
    }
}
