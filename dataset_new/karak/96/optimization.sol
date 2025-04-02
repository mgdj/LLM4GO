function allowlistVaultImpl(address vaultImpl) external onlyOwner {
    assembly {
        if iszero(vaultImpl) {
            mstore(0x00, 0x4e487b71) // Keccak256 of ZeroAddress() signature
            revert(0x00, 0x04)
        }
    }
    if (vaultImpl == Constants.DEFAULT_VAULT_IMPLEMENTATION_FLAG) revert ReservedAddress();

    _self().allowlistVaultImpl(vaultImpl);
}