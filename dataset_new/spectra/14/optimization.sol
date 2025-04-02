function _getCurrentPTandIBTRates(bool roundUpPTRate) internal view returns (uint256, uint256) {
        address _ibt = ibt;
        uint256 currentIBTRate = IERC4626(_ibt).previewRedeem(ibtUnit).toRay(_assetDecimals);
        
        if (IERC4626(_ibt).totalAssets() == 0 && IERC4626(_ibt).totalSupply() != 0) {
            currentIBTRate = 0;
        }
        uint256 currentPTRate = currentIBTRate < ibtRate
            ? ptRate.mulDiv(
                currentIBTRate,
                ibtRate,
                roundUpPTRate ? Math.Rounding.Ceil : Math.Rounding.Floor
            )
            : ptRate;
        return (currentPTRate, currentIBTRate);
    }