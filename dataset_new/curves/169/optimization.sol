function onBalanceChange(address token, address account) public payable onlyManager {
        TokenData storage data = tokensData[token];
        data.userFeeOffset[account] = data.cumulativeFeePerToken;
        if (balanceOf(token, account) > 0) userTokens[account].push(token);
    }