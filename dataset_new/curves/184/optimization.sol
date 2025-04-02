function updateFeeCredit(address token, address account) internal {
        
        uint256 balance = balanceOf(token, account);
        if (balance != 0) {
            TokenData storage data = tokensData[token];
            uint256 _cumulativeFeePerToken = data.cumulativeFeePerToken;
            data.unclaimedFees[account] += (_cumulativeFeePerToken - data.userFeeOffset[account]) * balance / PRECISION;
            data.userFeeOffset[account] = _cumulativeFeePerToken;
        }
    }