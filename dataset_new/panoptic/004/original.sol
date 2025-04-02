function absUint(int256 x) internal pure returns (uint256) {
    unchecked {
        return x > 0 ? uint256(x) : uint256(-x);
    }
}