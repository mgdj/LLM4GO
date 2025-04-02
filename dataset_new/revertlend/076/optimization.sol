function configToken(uint256 tokenId, PositionConfig calldata config) external {
    if (nonfungiblePositionManager.ownerOf(tokenId) != msg.sender) {
        revert Unauthorized();
    }

    if (config.isActive) {
        if (config.token0TriggerTick >= config.token1TriggerTick) {
            revert InvalidConfig();
        }
    }

    positionConfigs[tokenId] = config;

    emit PositionConfigured(
        tokenId,
        config.isActive,
        config.token0Swap,
        config.token1Swap,
        config.token0TriggerTick,
        config.token1TriggerTick,
        config.token0SlippageX64,
        config.token1SlippageX64,
        config.onlyFees,
        config.maxRewardX64
    );
}