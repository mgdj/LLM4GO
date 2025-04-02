function _validateData(address _token, uint256 _amount, Exchange _exchange, bytes calldata _data) internal view {
        address inputToken;
        address outputToken;
        uint256 inputTokenAmount;
        address recipient;
        bytes4 selector;

        if (_exchange == Exchange.UniswapV3) {
            (inputToken, outputToken, inputTokenAmount, recipient, selector) = _decodeUniswapV3Data(_data);
            if (selector != UNI_SELECTOR) {
                revert WrongSelector(selector);
            }
            // UniswapV3Feature.sellTokenForEthToUniswapV3(encodedPath, sellAmount, minBuyAmount, recipient) requires `encodedPath` to be a Uniswap-encoded path, where the last token is WETH, and sends the NATIVE token to `recipient`
            if (outputToken != address(WETH)) {
                revert WrongDataTokens(inputToken, outputToken);
            }
        } else if (_exchange == Exchange.TransformERC20) {
            (inputToken, outputToken, inputTokenAmount, selector) = _decodeTransformERC20Data(_data);
            if (selector != TRANSFORM_SELECTOR) {
                revert WrongSelector(selector);
            }
            if (outputToken != ETH) {
                revert WrongDataTokens(inputToken, outputToken);
            }
        } else {
            revert WrongExchange();
        }

        if (inputToken != _token) {
            revert WrongDataTokens(inputToken, outputToken);
        }
        if (inputTokenAmount != _amount) {
            revert WrongDataAmount(inputTokenAmount);
        }
        if (recipient != address(this) && recipient != address(0)) {
            revert WrongRecipient(recipient);
        }
    }