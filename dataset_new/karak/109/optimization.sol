    function validateVaultConfigs(Storage storage self, VaultLib.Config[] calldata vaultConfigs, address implementation)
        public
        view
    {
        if (!(implementation == address(0) || isVaultImplAllowlisted(self, implementation))) {
            revert VaultImplNotAllowlisted();
        }
        uint256 x = vaultConfigs.length
        for (uint256 i = 0; i < x; ) {
            if (self.assetSlashingHandlers[vaultConfigs[i].asset] == address(0)) revert AssetNotAllowlisted();
            unchecked{
                ++i;
            }
        }
    }