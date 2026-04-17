// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Config {
    // === SEPOLIA ADDRESSES ===

    address constant V2_ROUTER = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008; // UniswapV2

    address constant V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564; // SwapRouter

    address constant V3_QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6; // QuoterV2

    // Optional tokens for testing
    address constant WETH = 0xdd13E55209Fd76AfE204dBda4007C227904f0a81;

    address constant USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
}
