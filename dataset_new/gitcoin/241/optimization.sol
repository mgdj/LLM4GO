function extendCommunityStake(address stakee, uint64 duration) external whenNotPaused {
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

    Stake storage comStake = communityStakes[msg.sender][stakee];

    if (comStake.amount == 0) {
        revert AmountMustBeGreaterThanZero();
    }
    unchecked{
        uint64 unlockTime = duration + uint64(block.timestamp);
    }
    

    if (
        // 锁定时间必须在12周到104周之间
        unlockTime < comStake.unlockTime ||
        unlockTime < block.timestamp + 12 weeks ||
        unlockTime > block.timestamp + 104 weeks 
        // 必须晚于现有锁定时间
        
    ) {
        revert InvalidLockTime();
    }

    // 更新质押的锁定时间
    if(comStake.unlockTime != unlockTime){
        comStake.unlockTime = unlockTime;
    }
    

    emit CommunityStake(msg.sender, stakee, 0, unlockTime);
}