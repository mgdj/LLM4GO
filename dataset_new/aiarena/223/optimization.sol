function stakeNRN(uint256 amount, uint256 tokenId) external {
    // Check if the staking amount is greater than 0
    if (amount == 0) {
        revert ZeroAmount();
    }

    // Check if the caller owns the fighter (tokenId)
    if (_fighterFarmInstance.ownerOf(tokenId) != msg.sender) {
        revert NotFighterOwner(msg.sender, tokenId);
    }

    // Check if the caller has enough NRN balance to stake
    uint256 balance = _neuronInstance.balanceOf(msg.sender);
    if (balance < amount) {
        revert InsufficientBalance(balance, amount);
    }

    // Check if the token has already been unstaked in this round
    if (hasUnstaked[tokenId][roundId]) {
        revert AlreadyUnstaked(tokenId, roundId);
    }

    // Proceed with staking
    _neuronInstance.approveStaker(msg.sender, address(this), amount);
    bool success = _neuronInstance.transferFrom(msg.sender, address(this), amount);
    if (success) {
        // Update staking information
        if (amountStaked[tokenId] == 0) {
            _fighterFarmInstance.updateFighterStaking(tokenId, true);
        }
        amountStaked[tokenId] = amountStaked[tokenId] + amount;
        globalStakedAmount = globalStakedAmount + amount;
        stakingFactor[tokenId] = _getStakingFactor(
            tokenId, 
            _stakeAtRiskInstance.getStakeAtRisk(tokenId)
        );
        _calculatedStakingFactor[tokenId][roundId] = true;

        emit Staked(msg.sender, amount);
    }
}

error ZeroAmount();
error NotFighterOwner(address caller, uint256 tokenId);
error InsufficientBalance(uint256 available, uint256 required);
error AlreadyUnstaked(uint256 tokenId, uint256 roundId);