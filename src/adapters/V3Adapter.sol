// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IUniswapV3.sol";

contract V3Adapter {
    IUniswapV3Router public immutable router;
    IUniswapV3Quoter public immutable quoter;

    uint24[] public feeTiers = [500, 3000, 10000];

    constructor(address _router, address _quoter) {
        router = IUniswapV3Router(_router);
        quoter = IUniswapV3Quoter(_quoter);
    }

    function quoteBest(address tokenIn, address tokenOut, uint256 amountIn)
        external
        returns (uint256 bestOut, uint24 bestFee)
    {
        for (uint256 i = 0; i < feeTiers.length; i++) {
            try quoter.quoteExactInputSingle(tokenIn, tokenOut, feeTiers[i], amountIn, 0) returns (uint256 out) {
                if (out > bestOut) {
                    bestOut = out;
                    bestFee = feeTiers[i];
                }
            } catch {}
        }
    }

    function swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 minOut, uint24 fee)
        external
        returns (uint256 amountOut)
    {
        IUniswapV3Router.ExactInputSingleParams memory params = IUniswapV3Router.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: fee,
            recipient: address(this),
            amountIn: amountIn,
            amountOutMinimum: minOut,
            sqrtPriceLimitX96: 0
        });

        return router.exactInputSingle(params);
    }
}
