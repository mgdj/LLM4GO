/// @notice Write the "left" slot to a uint256 bit pattern.
/// @param self the original full uint256 bit pattern to be written to
/// @param left the bit pattern to write into the full pattern in the right half
/// @return self with left added to its left 128 bits
function toLeftSlot(uint256 self, uint128 left) internal pure returns (uint256) {
    unchecked {
        return self + (uint256(left) << 128);
    }
}