function communityStake(address stakee, uint88 amount, uint64 duration) external whenNotPaused {
    if (stakee == msg.sender) {
        revert CannotStakeOnSelf();
    }

    // 使用assembly检查address(0)
    assembly {
        if iszero(stakee) {
            mstore(0x00, 0x08c379a0) // keccak256("Error(string)") selector
            mstore(0x04, 0x20) // offset for the string
            mstore(0x24, 0x13) // length of string "AddressCannotBeZero"
            mstore(0x44, "AddressCannotBeZero") // the error message
            revert(0x00, 0x64) // revert with the error message
        }
    }

    if (amount == 0) {
        revert AmountMustBeGreaterThanZero();
    }

    uint64 unlockTime = duration + uint64(block.timestamp);

    if (
        // 锁定时间必须在12周到104周之间
        unlockTime < block.timestamp + 12 weeks ||
        unlockTime > block.timestamp + 104 weeks ||
        // 必须晚于现有锁定时间
        unlockTime < communityStakes[msg.sender][stakee].unlockTime
    ) {
        revert InvalidLockTime();
    }

    // 更新社区质押信息
    communityStakes[msg.sender][stakee].amount += amount;
    if(communityStakes[msg.sender][stakee].unlockTime!=unlockTime){
        communityStakes[msg.sender][stakee].unlockTime = unlockTime;
    }
    userTotalStaked[msg.sender] += amount;

    emit CommunityStake(msg.sender, stakee, amount, unlockTime);

    // 使用transferFrom完成质押转账
    if (!token.transferFrom(msg.sender, address(this), amount)) {
        revert FailedTransfer();
    }
}