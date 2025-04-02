    function allowlistAssets(Storage storage self, address[] memory assets, address[] memory slashingHandlers)
        external
    {
        if (assets.length != slashingHandlers.length) revert LengthsDontMatch();
        for (uint256 i = 0; i < assets.length; i++) {
            if (slashingHandlers[i] == address(0) || assets[i] == address(0)) revert ZeroAddress();
            self.assetSlashingHandlers[assets[i]] = slashingHandlers[i];
        }
    }