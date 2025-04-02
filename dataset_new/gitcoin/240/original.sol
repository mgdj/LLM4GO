function communityStake(address stakee, uint88 amount, uint64 duration) external whenNotPaused {
    if (stakee == msg.sender) {
      revert CannotStakeOnSelf();
    }
    if (stakee == address(0)) {
      revert AddressCannotBeZero();
    }
    if (amount == 0) {
      revert AmountMustBeGreaterThanZero();
    }

    uint64 unlockTime = duration + uint64(block.timestamp);

    if (
      // Must be between 12 weeks and 104 weeks
      unlockTime < block.timestamp + 12 weeks ||
      unlockTime > block.timestamp + 104 weeks ||
      // Must be later than any existing lock
      unlockTime < communityStakes[msg.sender][stakee].unlockTime
    ) {
      revert InvalidLockTime();
    }

    communityStakes[msg.sender][stakee].amount += amount;
    communityStakes[msg.sender][stakee].unlockTime = unlockTime;
    userTotalStaked[msg.sender] += amount;

    emit CommunityStake(msg.sender, stakee, amount, unlockTime);

    if (!token.transferFrom(msg.sender, address(this), amount)) {
      revert FailedTransfer();
    }
  }