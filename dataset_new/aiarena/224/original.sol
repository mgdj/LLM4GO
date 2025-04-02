function setNewRound(uint256 roundId_) external {
        require(msg.sender == _rankedBattleAddress, "Not authorized to set new round");
        bool success = _sweepLostStake();
        if (success) {
            roundId = roundId_;
        }
    }