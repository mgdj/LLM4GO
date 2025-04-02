function lockAndBurn() external whenNotPaused {
    if (block.timestamp - lastBurnTimestamp < burnRoundMinimumDuration) {
      revert MinimumBurnRoundDurationNotMet();
    }
    uint16 roundToBurn = currentSlashRound - 1;
    uint88 amountToBurn = totalSlashed[roundToBurn];

    ++currentSlashRound;
    lastBurnTimestamp = block.timestamp;

    if (amountToBurn != 0) {
      if (!token.transfer(burnAddress, amountToBurn)) {
        revert FailedTransfer();
      }
    }

    emit Burn(roundToBurn, amountToBurn);
  }