// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Config {
    // === SEPOLIA ADDRESSES ===

    address constant V2_ROUTER = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008; // UniswapV2

    address constant V3_ROUTER = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD; // SwapRouter

    address constant V3_QUOTER = 0xEd1f6473345F45b75F8179591dd5bA1888cf2FB3; // QuoterV2

    // Optional tokens for testing
    address constant WETH = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;

    address constant USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
}
