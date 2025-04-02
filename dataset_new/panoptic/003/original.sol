function convert0to1(int256 amount, uint160 sqrtPriceX96) internal pure returns (int256) {
    unchecked {
        // the tick 443636 is the maximum price where (price) * 2**192 fits into a uint256 (< 2**256-1)
        // above that tick, we are forced to reduce the amount of decimals in the final price by 2**64 to 2**128
        if (sqrtPriceX96 < 340275971719517849884101479065584693834) {
            int256 absResult = Math
                .mulDiv192(Math.absUint(amount), uint256(sqrtPriceX96) ** 2)
                .toInt256();
            return amount < 0 ? -absResult : absResult;
        } else {
            int256 absResult = Math
                .mulDiv128(Math.absUint(amount), Math.mulDiv64(sqrtPriceX96, sqrtPriceX96))
                .toInt256();
            return amount < 0 ? -absResult : absResult;
        }
    }
}