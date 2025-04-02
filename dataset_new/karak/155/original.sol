function allowlistVaultImpl(Storage storage self, address implementation) internal {
        self.allowlistedVaultImpl[implementation] = true;
    }