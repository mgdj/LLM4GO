function _updateFees(uint256 _feesInIBT) internal {
        unclaimedFeesInIBT = unclaimedFeesInIBT + _feesInIBT;
        totalFeesInIBT = totalFeesInIBT + _feesInIBT;
    }