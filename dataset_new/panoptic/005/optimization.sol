function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        unchecked {
            uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
            if (absTick > uint256(int256(Constants.MAX_V3POOL_TICK))) revert Errors.InvalidTick();

            uint256 sqrtR = absTick & 0x1 != 0
                ? 0xfffcb933bd6fad37aa2d162d1a594001
                : 0x100000000000000000000000000000000;
            // RealV: 0xfffcb933bd6fad37aa2d162d1a594001
            uint256[19] memory constants = [0xfffcb933bd6fad37aa2d162d1a594001, 0xfff97272373d413259a46990580e213a, /* ... other constants ... */];
            for (uint256 i = 0; i < 19; ++i) {
                if (absTick & (1 << i) != 0) {
                    sqrtR = (sqrtR * constants[i]) >> 128;
                }
            }
            // RealV: 0x48a170391f7dc42444e7be7

            if (tick > 0) sqrtR = type(uint256).max / sqrtR;

            // Downcast + rounding up to keep is consistent with Uniswap's
            sqrtPriceX96 = uint160((sqrtR >> 32) + (sqrtR % (1 << 32) == 0 ? 0 : 1));
        }
    }