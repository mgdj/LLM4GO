function _processLock(address _token, uint256 _amount, address _receiver, bytes32 _referral)
        internal
        onlyBeforeDate(loopActivation)
    {
        // Assembly to check if _amount is zero
        assembly {
            if iszero(_amount) {
                // Revert with a custom error
                mstore(0x00, 0x4e487b71) // Function selector for custom errors
                revert(0x00, 0x04)
            }
        }

        // Assembly to check if _token is ETH (ETH is a predefined constant)
        bool isETH;
        assembly {
            isETH := eq(_token, ETH)
        }

        if (isETH) {
            totalSupply += _amount;
            balances[_receiver][ETH] += _amount;
        } else {
            if (!isTokenAllowed[_token]) {
                revert TokenNotAllowed();
            }

            IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

            // If _token is WETH, convert WETH to ETH and update balances
            if (_token == address(WETH)) {
                WETH.withdraw(_amount);
                totalSupply += _amount;
                balances[_receiver][ETH] += _amount;
            } else {
                balances[_receiver][_token] += _amount;
            }
        }

        emit Locked(_receiver, _amount, _token, _referral);
    }