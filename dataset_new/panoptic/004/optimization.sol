function absUint(int256 x) internal pure returns (uint256) {
    return uint256(x < 0 ? -x : x);
}