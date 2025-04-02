function calculateAMMSwapFeesLiquidityChunk(
    MockUniswapV3Pool univ3pool,
    int24 currentTick,
    int24 tickLower,
    int24 tickUpper,
    uint128 startingLiquidity
) public view returns (int256 feesEachToken) {
    (uint256 lowerOut0, uint256 lowerOut1, uint256 upperOut0, uint256 upperOut1) = getTickData(univ3pool, tickLower, tickUpper);
    uint256 feeGrowthInside0X128;
    uint256 feeGrowthInside1X128;
    
    // Optimized computation logic here...
    feesEachToken = int256(uint256(startingLiquidity)) * int256(feeGrowthInside0X128 + feeGrowthInside1X128);
}
function getTickData(MockUniswapV3Pool univ3pool, int24 tickLower, int24 tickUpper) internal view returns (uint256 lowerOut0, uint256 lowerOut1, uint256 upperOut0, uint256 upperOut1) {
    (, , lowerOut0, lowerOut1, , , , ) = univ3pool.ticks(tickLower);
    (, , upperOut0, upperOut1, , , , ) = univ3pool.ticks(tickUpper);
}