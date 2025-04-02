function withdrawIBT(
        uint256 ibts,
        address receiver,
        address owner
    ) public override returns (uint256 shares) {
        address _ibt = ibt;
        _beforeWithdraw(IERC4626(_ibt).previewRedeem(ibts), owner);
        (uint256 _ptRate, uint256 _ibtRate) = _getPTandIBTRates(false);
        shares = _withdrawShares(ibts, receiver, owner, _ptRate, _ibtRate);
        // send IBTs from this contract to receiver
        IERC20(_ibt).safeTransfer(receiver, ibts);
    }