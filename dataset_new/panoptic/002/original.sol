function calculateAMMSwapFeesLiquidityChunk(
    MockUniswapV3Pool univ3pool,
    int24 currentTick,
    int24 tickLower,
    int24 tickUpper,
    uint128 startingLiquidity
) public view returns (int256 feesEachToken) {
    (, , uint256 lowerOut0, uint256 lowerOut1, , , , ) = univ3pool.ticks(tickLower);
    (, , uint256 upperOut0, uint256 upperOut1, , , , ) = univ3pool.ticks(tickUpper);
    unchecked {
        uint256 feeGrowthInside0X128;
        uint256 feeGrowthInside1X128;
        
        // ... original logic ...
        
        uint256 totalFeeGrowth = feeGrowthInside0X128 + feeGrowthInside1X128;
        feesEachToken = int256(uint256(startingLiquidity)) * int256(totalFeeGrowth);
    }
}