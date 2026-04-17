// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IUniswapV2.sol";

contract V2Adapter {
    IUniswapV2Router public immutable router;

    constructor(address _router) {
        router = IUniswapV2Router(_router);
    }

    function quote(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256 amountOut) {
        address[] memory path = new address[](2);
        address;
        path[0] = tokenIn;
        path[1] = tokenOut;

        try router.getAmountsOut(amountIn, path) returns (uint256[] memory amounts) {
            amountOut = amounts[1];
        } catch {
            amountOut = 0;
        }
    }

    function swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 minOut)
        external
        returns (uint256 amountOut)
    {
        address[] memory path = new address[](2);
        address;
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint256[] memory amounts =
            router.swapExactTokensForTokens(amountIn, minOut, path, address(this), block.timestamp);

        return amounts[1];
    }
}
