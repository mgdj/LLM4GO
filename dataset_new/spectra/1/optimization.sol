function getCurrentYieldOfUserInIBT(
        address _user
    ) external view override returns (uint256 _yieldOfUserInIBT) {
        uint256 _oldIBTRate = ibtRateOfUser[_user];
        if (_oldIBTRate != 0) {
            uint256 _oldPTRate = ptRateOfUser[_user];
            (uint256 _ptRate, uint256 _ibtRate) = _getPTandIBTRates(false);
            _yieldOfUserInIBT = PrincipalTokenUtil._computeYield(
                _user,
                yieldOfUserInIBT[_user],
                _oldIBTRate,
                _ibtRate,
                _oldPTRate,
                _ptRate,
                yt
            );
            _yieldOfUserInIBT -= PrincipalTokenUtil._computeYieldFee(_yieldOfUserInIBT, registry);
        }
    }