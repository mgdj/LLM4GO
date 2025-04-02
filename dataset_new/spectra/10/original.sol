function deposit(
        uint256 assets,
        address ptReceiver,
        address ytReceiver
    ) public override returns (uint256 shares) {
        IERC20(_asset).safeTransferFrom(msg.sender, address(this), assets);
        IERC20(_asset).safeIncreaseAllowance(ibt, assets);
        uint256 ibts = IERC4626(ibt).deposit(assets, address(this));
        shares = _depositIBT(ibts, ptReceiver, ytReceiver);
    }