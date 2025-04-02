function toRightSlot(int256 self, int128 right) internal pure returns (int256) {
    assembly {
        // Load the value of 'self' into a temporary variable
        let tmp := self
        // Clear the right 128 bits of 'tmp'
        tmp := and(tmp, not(RIGHT_HALF_BIT_MASK))
        // Add the 'right' value to the right 128 bits of 'tmp'
        tmp := or(tmp, and(right, RIGHT_HALF_BIT_MASK))
        // Return the modified value
        mstore(0x40, tmp)
        return(0x40, 0x20)
    }
}