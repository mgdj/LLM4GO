// function to configure a token to be used with this runner
// it needs to have approvals set for this contract beforehand
function configToken(uint256 tokenId, PositionConfig calldata config) external {
    address owner = nonfungiblePositionManager.ownerOf(tokenId);
    if (owner != msg.sender) {
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