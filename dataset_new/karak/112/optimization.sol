    function validateVaultsAndSlashPercentages(
        CoreLib.Storage storage self,
        SlashRequest memory slashingRequest,
        IDSS dss
    ) internal view {
        if (slashingRequest.vaults.hasDuplicates()) revert DuplicateSlashingVaults();

        uint256 maxSlashPercentageWad = getDSSMaxSlashablePercentageWad(self, dss);
        uint256 x = slashingRequest.vaults.length
        for (uint256 i = 0; i < x; i++) {
            if (!self.operatorState[slashingRequest.operator].isVaultStakeToDSS(dss, slashingRequest.vaults[i])) {
                revert VaultNotStakedToDSS();
            }
            if (slashingRequest.slashPercentagesWad[i] == 0) revert ZeroSlashPercentageWad();
            if (slashingRequest.slashPercentagesWad[i] > maxSlashPercentageWad) revert MaxSlashPercentageWadBreached();
        }
    }