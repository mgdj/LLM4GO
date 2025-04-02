function deposit(
        uint256 assets,
        address ptReceiver,
        address ytReceiver
    ) public override returns (uint256 shares) {
        IERC20(_asset).safeTransferFrom(msg.sender, address(this), assets);
        address _ibt == ibt;
        IERC20(_asset).safeIncreaseAllowance(_ibt, assets);
        uint256 ibts = IERC4626(_ibt).deposit(assets, address(this));
        shares = _depositIBT(ibts, ptReceiver, ytReceiver);
    }