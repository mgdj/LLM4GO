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

    // Assembly to check if inputToken is address(0)
    assembly {
        if iszero(inputToken) {
            mstore(0x00, 0x4e487b71) // Custom error selector for WrongDataTokens
            revert(0x00, 0x04)
        }
    }

    // Assembly to check if recipient is address(0) or this contract address
    assembly {
        if or(iszero(recipient), eq(recipient, address())) {
            // If recipient is address(0) or contract address, continue, else revert
        } else {
            mstore(0x00, 0x4e487b71) // Custom error selector for WrongRecipient
            revert(0x00, 0x04)
        }
    }

    if (inputToken != _token) {
        revert WrongDataTokens(inputToken, outputToken);
    }
    if (inputTokenAmount != _amount) {
        revert WrongDataAmount(inputTokenAmount);
    }
}