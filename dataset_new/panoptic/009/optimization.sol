function getAmount1ForLiquidity(uint256 liquidityChunk) internal pure returns (uint160 lowPriceX96, uint160 highPriceX96) {
    lowPriceX96 = getSqrtRatioAtTick(liquidityChunk.tickLower());
    highPriceX96 = getSqrtRatioAtTick(liquidityChunk.tickUpper());
}
// Refactor the original functions to use calculatePriceX96