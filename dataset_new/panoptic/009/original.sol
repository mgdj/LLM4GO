function getAmount1ForLiquidity(uint256 liquidityChunk) internal pure returns (uint256 amount1) {
    uint160 lowPriceX96 = getSqrtRatioAtTick(liquidityChunk.tickLower());
    uint160 highPriceX96 = getSqrtRatioAtTick(liquidityChunk.tickUpper());
    // ...
}
function getLiquidityForAmount1(uint256 liquidityChunk, uint256 amount1) internal pure returns (uint128 liquidity) {
    uint160 lowPriceX96 = getSqrtRatioAtTick(liquidityChunk.tickLower());
    uint160 highPriceX96 = getSqrtRatioAtTick(liquidityChunk.tickUpper());
    // ...
}