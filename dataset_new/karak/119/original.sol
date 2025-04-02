    function validateStakeUpdateRequest(State storage operatorState, StakeUpdateRequest memory stakeUpdate)
        internal
        view
    {
        if (operatorState.pendingStakeUpdates[stakeUpdate.vault] != bytes32(0)) revert PendingStakeUpdateRequest();
        if (!operatorState.vaults.contains(stakeUpdate.vault)) revert VaultNotAChildVault();
    }