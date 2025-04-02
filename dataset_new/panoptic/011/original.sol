function getFinalPoolId(
        uint64 basePoolId,
        address token0,
        address token1,
        uint24 fee
    ) internal pure returns (uint64) {
        unchecked {
            return
                basePoolId +
                (uint64(uint256(keccak256(abi.encodePacked(token0, token1, fee)))) >> 32);
        }
    }