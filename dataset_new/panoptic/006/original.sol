function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        unchecked {
            uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
            if (absTick > uint256(int256(Constants.MAX_V3POOL_TICK))) revert Errors.InvalidTick();

            uint256 sqrtR = absTick & 0x1 != 0
                ? 0xfffcb933bd6fad37aa2d162d1a594001
                : 0x100000000000000000000000000000000;
            // RealV: 0xfffcb933bd6fad37aa2d162d1a594001
            if (absTick & 0x2 != 0) sqrtR = (sqrtR * 0xfff97272373d413259a46990580e213a) >> 128;
            // RealV: 0xfff97272373d413259a46990580e2139
            if (absTick & 0x4 != 0) sqrtR = (sqrtR * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
            // RealV: 0xfff2e50f5f656932ef12357cf3c7fdca
            if (absTick & 0x8 != 0) sqrtR = (sqrtR * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
            // RealV: 0xffe5caca7e10e4e61c3624eaa0941ccd
            if (absTick & 0x10 != 0) sqrtR = (sqrtR * 0xffcb9843d60f6159c9db58835c926644) >> 128;
            // RealV: 0xffcb9843d60f6159c9db58835c92663e
            if (absTick & 0x20 != 0) sqrtR = (sqrtR * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
            // RealV: 0xff973b41fa98c081472e6896dfb254b6
            if (absTick & 0x40 != 0) sqrtR = (sqrtR * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
            // RealV: 0xff2ea16466c96a3843ec78b326b5284f
            if (absTick & 0x80 != 0) sqrtR = (sqrtR * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
            // RealV: 0xfe5dee046a99a2a811c461f1969c3032
            if (absTick & 0x100 != 0) sqrtR = (sqrtR * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
            // RealV: 0xfcbe86c7900a88aedcffc83b479aa363
            if (absTick & 0x200 != 0) sqrtR = (sqrtR * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
            // RealV: 0xf987a7253ac413176f2b074cf7815dd0
            if (absTick & 0x400 != 0) sqrtR = (sqrtR * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
            // RealV: 0xf3392b0822b70005940c7a398e4b6ff1
            if (absTick & 0x800 != 0) sqrtR = (sqrtR * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
            // RealV: 0xe7159475a2c29b7443b29c7fa6e887f2
            if (absTick & 0x1000 != 0) sqrtR = (sqrtR * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
            // RealV: 0xd097f3bdfd2022b8845ad8f792aa548c
            if (absTick & 0x2000 != 0) sqrtR = (sqrtR * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
            // RealV: 0xa9f746462d870fdf8a65dc1f90e05b52
            if (absTick & 0x4000 != 0) sqrtR = (sqrtR * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
            // RealV: 0x70d869a156d2a1b890bb3df62baf27ff
            if (absTick & 0x8000 != 0) sqrtR = (sqrtR * 0x31be135f97d08fd981231505542fcfa6) >> 128;
            // RealV: 0x31be135f97d08fd981231505542fbfe8
            if (absTick & 0x10000 != 0) sqrtR = (sqrtR * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
            // RealV: 0x9aa508b5b7a84e1c677de54f3e988fe
            if (absTick & 0x20000 != 0) sqrtR = (sqrtR * 0x5d6af8dedb81196699c329225ee604) >> 128;
            // RealV: 0x5d6af8dedb81196699c329225ed28d
            if (absTick & 0x40000 != 0) sqrtR = (sqrtR * 0x2216e584f5fa1ea926041bedfe98) >> 128;
            // RealV: 0x2216e584f5fa1ea926041bedeaf4
            if (absTick & 0x80000 != 0) sqrtR = (sqrtR * 0x48a170391f7dc42444e8fa2) >> 128;
            // RealV: 0x48a170391f7dc42444e7be7

            if (tick > 0) sqrtR = type(uint256).max / sqrtR;

            // Downcast + rounding up to keep is consistent with Uniswap's
            sqrtPriceX96 = uint160((sqrtR >> 32) + (sqrtR % (1 << 32) == 0 ? 0 : 1));
        }
    }