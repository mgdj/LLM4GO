function validateVaultConfigs(
    Storage storage self, 
    VaultLib.Config[] calldata vaultConfigs, 
    address implementation
) public view {
    assembly {
        // Check if implementation is address(0)
        if iszero(implementation) {
            // Do nothing, as address(0) is valid
        } else {
            // Check if the implementation is allowlisted
            let allowlisted := isVaultImplAllowlisted(sload(self.slot), implementation)
            if iszero(allowlisted) {
                mstore(0x00, 0x6c4b7ee1) // Custom error selector for VaultImplNotAllowlisted()
                revert(0x00, 0x04)
            }
        }
    }

    for (uint256 i = 0; i < vaultConfigs.length; i++) {
        assembly {
            // Load the asset from vaultConfigs[i]
            let asset := sload(add(add(vaultConfigs, mul(i, 0x20)), 0x20))
            // Check if assetSlashingHandlers[asset] is address(0)
            if iszero(sload(add(self.slot, asset))) {
                mstore(0x00, 0x49d93ed9) // Custom error selector for AssetNotAllowlisted()
                revert(0x00, 0x04)
            }
        }
    }
}