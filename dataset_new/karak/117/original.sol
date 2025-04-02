    function requestUpdateVaultStakeInDSS(Operator.StakeUpdateRequest memory vaultStakeUpdateRequest)
        external
        nonReentrant
        whenFunctionNotPaused(Constants.PAUSE_CORE_REQUEST_STAKE_UPDATE)
        returns (Operator.QueuedStakeUpdate memory updatedStake)
    {
        address operator = msg.sender;
        CoreLib.Storage storage self = _self();
        self.checkIfOperatorIsRegInRegDSS(operator, vaultStakeUpdateRequest.dss);
        updatedStake = self.requestUpdateVaultStakeInDSS(vaultStakeUpdateRequest, self.nonce++, operator);
        emit RequestedStakeUpdate(updatedStake);
    }