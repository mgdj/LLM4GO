function allowlistAssets(
    Storage storage self, 
    address[] memory assets, 
    address[] memory slashingHandlers
) external {
    if (assets.length != slashingHandlers.length) revert LengthsDontMatch();
    
    for (uint256 i = 0; i < assets.length; i++) {
        assembly {
            // Check if assets[i] or slashingHandlers[i] are address(0)
            if or(iszero(mload(add(assets, mul(add(i, 1), 0x20)))), iszero(mload(add(slashingHandlers, mul(add(i, 1), 0x20))))) {
                mstore(0x00, 0x4e487b71) // Custom error selector for ZeroAddress()
                revert(0x00, 0x04)
            }
        }
        self.assetSlashingHandlers[assets[i]] = slashingHandlers[i];
    }
}