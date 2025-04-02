function slash(
    address[] calldata selfStakers,
    address[] calldata communityStakers,
    address[] calldata communityStakees,
    uint88 percent
  ) external onlyRole(SLASHER_ROLE) whenNotPaused {
    if (percent == 0 || percent > 100) {
      revert InvalidSlashPercent();
    }

    uint256 numSelfStakers = selfStakers.length;
    uint256 numCommunityStakers = communityStakers.length;

    if (numCommunityStakers != communityStakees.length) {
      revert StakerStakeeMismatch();
    }
    uint16 x = currentSlashRound;
    for (uint256 i = 0; i < numSelfStakers;) {
      address staker = selfStakers[i];
      uint88 slashedAmount = (percent * selfStakes[staker].amount) / 100;

      Stake storage sStake = selfStakes[staker];

      if (sStake.slashedInRound != 0 && sStake.slashedInRound != x) {
        if (sStake.slashedInRound == x - 1) {
          // If this is a slash from the previous round (not yet burned), move
          // it to the current round
          totalSlashed[x - 1] -= sStake.slashedAmount;
          totalSlashed[x] += sStake.slashedAmount;
        } else {
          // Otherwise, this is a stale slash and can be overwritten
          sStake.slashedAmount = 0;
        }
      }

      totalSlashed[x] += slashedAmount;
      if(sStake.slashedInRound != x){
        sStake.slashedInRound = x;
      }
      sStake.slashedAmount = sStake.slashedAmount + slashedAmount;
      sStake.amount = sStake.amount - slashedAmount;

      userTotalStaked[staker] -= slashedAmount;

      emit Slash(staker, slashedAmount, x);
      unchecked{
        ++i;
      }
    }

    for (uint256 i = 0; i < numCommunityStakers;) {
      address staker = communityStakers[i];
      address stakee = communityStakees[i];
      uint88 slashedAmount = (percent * communityStakes[staker][stakee].amount) / 100;

      Stake storage comStake = communityStakes[staker][stakee];

      if (comStake.slashedInRound != 0 && comStake.slashedInRound != x) {
        if (comStake.slashedInRound == x - 1) {
          // If this is a slash from the previous round (not yet burned), move
          // it to the current round
          totalSlashed[x - 1] -= comStake.slashedAmount;
          totalSlashed[x] += comStake.slashedAmount;
        } else {
          // Otherwise, this is a stale slash and can be overwritten
          comStake.slashedAmount = 0;
        }
      }

      totalSlashed[x] += slashedAmount;

      if(comStake.slashedInRound != x){
        comStake.slashedInRound = x;
      }
      comStake.slashedAmount = comStake.slashedAmount + slashedAmount;
      comStake.amount = comStake.amount - slashedAmount;

      userTotalStaked[staker] -= slashedAmount;

      emit Slash(staker, slashedAmount, x);
      unchecked{
        ++i;
      }
    }
  }