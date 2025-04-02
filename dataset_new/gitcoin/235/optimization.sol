function selfStake(uint88 amount, uint64 duration) external whenNotPaused {
    if (amount == 0) {
      revert AmountMustBeGreaterThanZero();
    }
    unchecked{uint64 unlockTime = duration + uint64(block.timestamp);}
    

    if (
      // Must be between 12 weeks and 104 weeks
      unlockTime < block.timestamp + 12 weeks ||
      unlockTime > block.timestamp + 104 weeks ||
      // Must be later than any existing lock
      unlockTime < selfStakes[msg.sender].unlockTime
    ) {
      revert InvalidLockTime();
    }

    selfStakes[msg.sender].amount += amount;
    if(selfStake[msg.sender].unlockTime != unlockTime){
        selfStakes[msg.sender].unlockTime = unlockTime;
    }
    
    userTotalStaked[msg.sender] += amount;

    emit SelfStake(msg.sender, amount, unlockTime);

    if (!token.transferFrom(msg.sender, address(this), amount)) {
      revert FailedTransfer();
    }
  }