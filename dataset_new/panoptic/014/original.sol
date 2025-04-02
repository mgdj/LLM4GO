/// @notice Write the "right" slot to an int256.
/// @param self the original full int256 bit pattern to be written to
/// @param right the bit pattern to write into the full pattern in the right half
/// @return self with right added to its right 128 bits
function toRightSlot(int256 self, int128 right) internal pure returns (int256) {
    unchecked {
        return self + (int256(right) & RIGHT_HALF_BIT_MASK);
    }
}