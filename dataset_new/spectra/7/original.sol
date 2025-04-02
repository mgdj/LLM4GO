function _updateFees(uint256 _feesInIBT) internal {
        unclaimedFeesInIBT += _feesInIBT;
        totalFeesInIBT += _feesInIBT;
    }