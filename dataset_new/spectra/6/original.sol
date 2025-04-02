function _computeYield(
        address _user,
        uint256 _userYieldIBT,
        uint256 _oldIBTRate,
        uint256 _ibtRate,
        uint256 _oldPTRate,
        uint256 _ptRate,
        address _yt
    ) external view returns (uint256) {
        if (_oldPTRate == _ptRate && _ibtRate == _oldIBTRate) {
            return _userYieldIBT;
        }
        uint256 newYieldInIBTRay;
        uint256 userYTBalanceInRay = IYieldToken(_yt).actualBalanceOf(_user).toRay(
            IYieldToken(_yt).decimals()
        );
        // ibtOfPT is the yield generated by each PT corresponding to the YTs that the user holds
        uint256 ibtOfPTInRay = userYTBalanceInRay.mulDiv(_oldPTRate, _oldIBTRate);
        if (_oldPTRate == _ptRate && _ibtRate > _oldIBTRate) {
            // only positive yield happened
            newYieldInIBTRay = ibtOfPTInRay.mulDiv(_ibtRate - _oldIBTRate, _ibtRate);
        } else {
            if (_oldPTRate > _ptRate) {
                // PT depeg happened
                uint256 yieldInAssetRay;
                if (_ibtRate >= _oldIBTRate) {
                    // both negative and positive yield happened, more positive
                    yieldInAssetRay =
                        _convertToAssetsWithRate(
                            userYTBalanceInRay,
                            _oldPTRate - _ptRate,
                            RayMath.RAY_UNIT,
                            Math.Rounding.Floor
                        ) +
                        _convertToAssetsWithRate(
                            ibtOfPTInRay,
                            _ibtRate - _oldIBTRate,
                            RayMath.RAY_UNIT,
                            Math.Rounding.Floor
                        );
                } else {
                    // either both negative and positive yield happened, more negative
                    // or only negative yield happened
                    uint256 actualNegativeYieldInAssetRay = _convertToAssetsWithRate(
                        userYTBalanceInRay,
                        _oldPTRate - _ptRate,
                        RayMath.RAY_UNIT,
                        Math.Rounding.Floor
                    );
                    uint256 expectedNegativeYieldInAssetRay = Math.ceilDiv(
                        ibtOfPTInRay * (_oldIBTRate - _ibtRate),
                        RayMath.RAY_UNIT
                    );
                    yieldInAssetRay = expectedNegativeYieldInAssetRay >
                        actualNegativeYieldInAssetRay
                        ? 0
                        : actualNegativeYieldInAssetRay - expectedNegativeYieldInAssetRay;
                    yieldInAssetRay = yieldInAssetRay.fromRay(
                        IERC4626(IPrincipalToken(IYieldToken(_yt).getPT()).underlying()).decimals()
                    ) < SAFETY_BOUND
                        ? 0
                        : yieldInAssetRay;
                }
                newYieldInIBTRay = _convertToSharesWithRate(
                    yieldInAssetRay,
                    _ibtRate,
                    RayMath.RAY_UNIT,
                    Math.Rounding.Floor
                );
            } else {
                // PT rate increased or did not depeg on IBT rate decrease
                revert IPrincipalToken.RateError();
            }
        }
        return _userYieldIBT + newYieldInIBTRay.fromRay(IERC20Metadata(_yt).decimals());
    }