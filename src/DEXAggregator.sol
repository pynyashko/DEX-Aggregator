// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./adapters/V2Adapter.sol";
import "./adapters/V3Adapter.sol";
import "./utils/Errors.sol";

contract DexAggregator is
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    V2Adapter public v2;
    V3Adapter public v3;

    bool public paused;

    event Swap(address user, address tokenIn, address tokenOut, uint amountIn, uint amountOut);

    modifier notPaused() {
        if (paused) revert Errors.Paused();
        _;
    }

    function initialize(address _v2, address _v3) external initializer {
        __Ownable_init(msg.sender);

        v2 = V2Adapter(_v2);
        v3 = V3Adapter(_v3);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function setPaused(bool _p) external onlyOwner {
        paused = _p;
    }

    function getBestQuote(
    address tokenIn,
    address tokenOut,
    uint amountIn
)
    external
    returns (uint bestOut, bool useV3, uint24 fee)
{
    uint v2Out = v2.quote(tokenIn, tokenOut, amountIn);
    (uint v3Out, uint24 bestFee) = v3.quoteBest(tokenIn, tokenOut, amountIn);

    if (v2Out == 0 && v3Out == 0) {
        revert Errors.NoRouteFound();
    }

    if (v3Out > v2Out) {
        return (v3Out, true, bestFee);
    } else {
        return (v2Out, false, 0);
    }
}

    function swap(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint minOut
    ) external nonReentrant notPaused returns (uint amountOut) {

        if (amountIn == 0) revert Errors.ZeroAmount();
        if (tokenIn == tokenOut) revert Errors.InvalidToken();

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);

        // Approvals
        IERC20(tokenIn).approve(address(v2), amountIn);
        IERC20(tokenIn).approve(address(v3), amountIn);

        // Quotes
        uint v2Out = v2.quote(tokenIn, tokenOut, amountIn);
        (uint v3Out, uint24 fee) = v3.quoteBest(tokenIn, tokenOut, amountIn);

        if (v2Out == 0 && v3Out == 0) revert Errors.NoRouteFound();

        bool useV3 = v3Out > v2Out;

        if (useV3) {
            amountOut = v3.swap(tokenIn, tokenOut, amountIn, minOut, fee);
        } else {
            amountOut = v2.swap(tokenIn, tokenOut, amountIn, minOut);
        }

        if (amountOut < minOut) revert Errors.SlippageExceeded();

        IERC20(tokenOut).safeTransfer(msg.sender, amountOut);

        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }
}