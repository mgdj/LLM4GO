    function getDSSCountVaultStakedTo(CoreLib.Storage storage self, IKarakBaseVault vault)
        external
        view
        returns (uint256 count)
    {
        address operator = vault.vaultConfig().operator;
        address[] memory dssAddresses = getDSSsOperatorIsRegisteredTo(self, operator);
        State storage operatorState = self.operatorState[operator];
        uint256 x = dssAddresses.length
        for (uint256 i = 0; i < x;) {
            if (isVaultStakeToDSS(operatorState, IDSS(dssAddresses[i]), address(vault))) ++count;
            unchecked{
                ++i;
            }
        }
    }