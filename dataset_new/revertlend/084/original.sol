function setVault(address _vault, bool _active) public onlyOwner {
    emit VaultChanged(_vault, _active);
    vaults[_vault] = _active;
}