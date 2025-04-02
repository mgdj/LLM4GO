function changeStandardImplementation(address newVaultImpl) external onlyOwner {
    assembly {
        if iszero(newVaultImpl) {
            mstore(0x00, 0x4e487b71) // Keccak256 of ZeroAddress() signature
            revert(0x00, 0x04)
        }
    }
    if (newVaultImpl == Constants.DEFAULT_VAULT_IMPLEMENTATION_FLAG) revert ReservedAddress();
    
    _self().vaultImpl = newVaultImpl;
    emit UpgradedAllVaults(newVaultImpl);
}