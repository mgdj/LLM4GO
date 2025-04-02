function toLeftSlot(uint256 self, uint128 left) internal pure returns (uint256) {
    unchecked {
        // Clear the left 128 bits of 'self' before packing to ensure clean insertion of 'left'
        uint256 clearedSelf = self & uint256(type(uint128).max);
        // Efficiently pack 'left' into the cleared left 128 bits of 'self'
        return clearedSelf | (uint256(left) << 128);
    }
}