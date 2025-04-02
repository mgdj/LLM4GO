function setVault(address _vault, bool _active) public onlyOwner {
    if (vaults[_vaults] != _active) {
        emit VaultChanged(_vault, _active);
        vaults[_vault] = _active;
    }
}