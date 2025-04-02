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
                assembly {
                    let m := mload(0x40) // Load free memory pointer
                    mstore(m, amount)    // Store amount at memory location m
                    mstore(add(m, 0x20), sqrtPriceX96) // Store sqrtPriceX96 next to amount
                    // Perform the multiplication and division inline
                    absResult := div(mul(mload(m), mload(add(m, 0x20))), 0x100000000000000000000000000000000)
                }
                return amount < 0 ? -absResult : absResult;
            }
        }
    }