function startRedeem(uint256 shares, address beneficiary)
    external
    whenFunctionNotPaused(Constants.PAUSE_VAULT_START_REDEEM)
    nonReentrant
    returns (bytes32 withdrawalKey)
{
    // Assembly block to check for shares == 0 and beneficiary == address(0)
    assembly {
        if or(iszero(shares), iszero(beneficiary)) {
            if iszero(shares) {
                mstore(0x00, 0x3e0d7547) // Custom error selector for ZeroShares()
                revert(0x00, 0x04)
            }
            if iszero(beneficiary) {
                mstore(0x00, 0x4e487b71) // Custom error selector for ZeroAddress()
                revert(0x00, 0x04)
            }
        }
    }

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