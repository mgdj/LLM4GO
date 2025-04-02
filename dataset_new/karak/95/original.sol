    function changeStandardImplementation(address newVaultImpl) external onlyOwner {
        if (newVaultImpl == address(0)) revert ZeroAddress();
        if (newVaultImpl == Constants.DEFAULT_VAULT_IMPLEMENTATION_FLAG) revert ReservedAddress();
        _self().vaultImpl = newVaultImpl;
        emit UpgradedAllVaults(newVaultImpl);
    }