function sub(int256 x, int256 y) internal pure returns (int256 z) {
    unchecked {
        // Simultaneously perform subtraction and type casting to reduce operations
        int128 left128 = int128(int256(x.leftSlot()) - y.leftSlot());
        int128 right128 = int128(int256(x.rightSlot()) - y.rightSlot());
        // Utilize arithmetic shift for overflow/underflow checks instead of direct comparison
        // This is generally more gas-efficient in the EVM
        if ((left128 >> 127 != (x.leftSlot() - y.leftSlot()) >> 127) ||
            (right128 >> 127 != (x.rightSlot() - y.rightSlot()) >> 127)) {
            revert Errors.UnderOverFlow();
        }
        // Employ bitwise operations for final combination of left and right slots
        // Bitwise operations are typically less gas-intensive than arithmetic operations in EVM
        z = int256(right128) | (int256(left128) << 128);
    }
}