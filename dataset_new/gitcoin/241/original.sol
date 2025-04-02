function extendCommunityStake(address stakee, uint64 duration) external whenNotPaused {
    if (stakee == address(0)) {
      revert AddressCannotBeZero();
    }

    Stake storage comStake = communityStakes[msg.sender][stakee];

    if (comStake.amount == 0) {
      revert AmountMustBeGreaterThanZero();
    }

    uint64 unlockTime = duration + uint64(block.timestamp);

    if (
      // Must be between 12 weeks and 104 weeks
      unlockTime < block.timestamp + 12 weeks ||
      unlockTime > block.timestamp + 104 weeks ||
      // Must be later than any existing lock
      unlockTime < comStake.unlockTime
    ) {
      revert InvalidLockTime();
    }

    comStake.unlockTime = unlockTime;

    emit CommunityStake(msg.sender, stakee, 0, unlockTime);
  }