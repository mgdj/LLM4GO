constructor(address _exchangeProxy, address _wethAddress, address[] memory _allowedTokens) {
        owner = msg.sender;
        exchangeProxy = _exchangeProxy;
        WETH = IWETH(_wethAddress);

        loopActivation = uint32(block.timestamp + 120 days);
        startClaimDate = 4294967295; // Max uint32 ~ year 2107

        // Allow intital list of tokens
        uint256 length = _allowedTokens.length;
        for (uint256 i = 0; i < length;) {
            isTokenAllowed[_allowedTokens[i]] = true;
            unchecked {
                ++i;
            }
        }
        isTokenAllowed[_wethAddress] = true;
    }