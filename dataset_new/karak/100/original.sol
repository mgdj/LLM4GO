    function startRedeem(uint256 shares, address beneficiary)
        external
        whenFunctionNotPaused(Constants.PAUSE_VAULT_START_REDEEM)
        nonReentrant
        returns (bytes32 withdrawalKey)
    {
        if (shares == 0) revert ZeroShares();
        if (beneficiary == address(0)) revert ZeroAddress();

        (VaultLib.State storage state, VaultLib.Config storage config) = _storage();
        address staker = msg.sender;

        uint256 assets = convertToAssets(shares);

        withdrawalKey = WithdrawLib.calculateWithdrawKey(staker, state.stakerToWithdrawNonce[staker]++);

        state.withdrawalMap[withdrawalKey].staker = staker;
        state.withdrawalMap[withdrawalKey].start = uint96(block.timestamp);
        state.withdrawalMap[withdrawalKey].shares = shares;
        state.withdrawalMap[withdrawalKey].beneficiary = beneficiary;

        this.transferFrom(msg.sender, address(this), shares);

        emit StartedRedeem(staker, config.operator, shares, withdrawalKey, assets);
    }