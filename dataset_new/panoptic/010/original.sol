function getPoolId(address univ3pool) internal pure returns (uint64) {
        return uint64(uint160(univ3pool) >> 96);
    }