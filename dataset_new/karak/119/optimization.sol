function validateStakeUpdateRequest(State storage operatorState, StakeUpdateRequest calldata stakeUpdate)
        internal
        view
    {
        if (operatorState.pendingStakeUpdates[stakeUpdate.vault] != bytes32(0)) revert PendingStakeUpdateRequest();
        if (!operatorState.vaults.contains(stakeUpdate.vault)) revert VaultNotAChildVault();
    }