function setReward(uint64 _totalRewardX64) external onlyOwner {
    if (_totalRewardX64 > totalRewardX64) {
        // 使用自定义错误
        revert TotalRewardExceeded(totalRewardX64, _totalRewardX64);
    }

    if (_totalRewardX64 != totalRewardX64) {
        totalRewardX64 = _totalRewardX64;
        emit RewardUpdated(msg.sender, _totalRewardX64);
    }
}
error TotalRewardExceeded(uint64 totalRewardX64, uint64 requestedReward);