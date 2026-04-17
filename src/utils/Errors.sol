// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Errors {
    error SlippageExceeded();
    error InvalidToken();
    error ZeroAmount();
    error Paused();
    error NoRouteFound();
}
