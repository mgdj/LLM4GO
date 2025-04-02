function totalAssets() public view override returns (uint256) {
        address _ibt = ibt;
        return IERC4626(_ibt).previewRedeem(IERC4626(_ibt).balanceOf(address(this)));
    }