    function setReward(uint64 _totalRewardX64) external onlyOwner {
        require(_totalRewardX64 <= totalRewardX64, ">totalRewardX64");
        totalRewardX64 = _totalRewardX64;
        emit RewardUpdated(msg.sender, _totalRewardX64);
    }