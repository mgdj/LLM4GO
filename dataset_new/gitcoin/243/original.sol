function slash(
    address[] calldata selfStakers,
    address[] calldata communityStakers,
    address[] calldata communityStakees,
    uint88 percent
  ) external onlyRole(SLASHER_ROLE) whenNotPaused {
    if (percent > 100 || percent == 0) {
      revert InvalidSlashPercent();
    }

    uint256 numSelfStakers = selfStakers.length;
    uint256 numCommunityStakers = communityStakers.length;

    if (numCommunityStakers != communityStakees.length) {
      revert StakerStakeeMismatch();
    }

    for (uint256 i = 0; i < numSelfStakers; i++) {
      address staker = selfStakers[i];
      uint88 slashedAmount = (percent * selfStakes[staker].amount) / 100;

      Stake storage sStake = selfStakes[staker];

      if (sStake.slashedInRound != 0 && sStake.slashedInRound != currentSlashRound) {
        if (sStake.slashedInRound == currentSlashRound - 1) {
          // If this is a slash from the previous round (not yet burned), move
          // it to the current round
          totalSlashed[currentSlashRound - 1] -= sStake.slashedAmount;
          totalSlashed[currentSlashRound] += sStake.slashedAmount;
        } else {
          // Otherwise, this is a stale slash and can be overwritten
          sStake.slashedAmount = 0;
        }
      }

      totalSlashed[currentSlashRound] += slashedAmount;

      sStake.slashedInRound = currentSlashRound;
      sStake.slashedAmount += slashedAmount;
      sStake.amount -= slashedAmount;

      userTotalStaked[staker] -= slashedAmount;

      emit Slash(staker, slashedAmount, currentSlashRound);
    }

    for (uint256 i = 0; i < numCommunityStakers; i++) {
      address staker = communityStakers[i];
      address stakee = communityStakees[i];
      uint88 slashedAmount = (percent * communityStakes[staker][stakee].amount) / 100;

      Stake storage comStake = communityStakes[staker][stakee];

      if (comStake.slashedInRound != 0 && comStake.slashedInRound != currentSlashRound) {
        if (comStake.slashedInRound == currentSlashRound - 1) {
          // If this is a slash from the previous round (not yet burned), move
          // it to the current round
          totalSlashed[currentSlashRound - 1] -= comStake.slashedAmount;
          totalSlashed[currentSlashRound] += comStake.slashedAmount;
        } else {
          // Otherwise, this is a stale slash and can be overwritten
          comStake.slashedAmount = 0;
        }
      }

      totalSlashed[currentSlashRound] += slashedAmount;

      comStake.slashedInRound = currentSlashRound;
      comStake.slashedAmount += slashedAmount;
      comStake.amount -= slashedAmount;

      userTotalStaked[staker] -= slashedAmount;

      emit Slash(staker, slashedAmount, currentSlashRound);
    }
  }