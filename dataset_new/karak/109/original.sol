    function validateVaultConfigs(Storage storage self, VaultLib.Config[] calldata vaultConfigs, address implementation)
        public
        view
    {
        if (!(implementation == address(0) || isVaultImplAllowlisted(self, implementation))) {
            revert VaultImplNotAllowlisted();
        }
        for (uint256 i = 0; i < vaultConfigs.length; i++) {
            if (self.assetSlashingHandlers[vaultConfigs[i].asset] == address(0)) revert AssetNotAllowlisted();
        }
    }