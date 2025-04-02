function totalAssets() public view override returns (uint256) {
        return IERC4626(ibt).previewRedeem(IERC4626(ibt).balanceOf(address(this)));
    }