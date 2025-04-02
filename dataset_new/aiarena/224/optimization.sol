function setNewRound(uint256 roundId_) external {
    // Check if the caller is the ranked battle address
    if (msg.sender != _rankedBattleAddress) {
        revert NotAuthorized(msg.sender);
    }

    // Proceed with sweeping lost stake and updating the round
    if (_sweepLostStake()) {
        if(roundId!=roundId_){
            roundId = roundId_;
        }
    }
}

error NotAuthorized(address caller);