function allowlistVaultImpl(address vaultImpl) external payable onlyOwner {
        if (vaultImpl == address(0)) revert ZeroAddress();
        if (vaultImpl == Constants.DEFAULT_VAULT_IMPLEMENTATION_FLAG) revert ReservedAddress();

        _self().allowlistVaultImpl(vaultImpl);
    }