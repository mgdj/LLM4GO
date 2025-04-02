function _processLock(address _token, uint256 _amount, address _receiver, bytes32 _referral)
        internal
        onlyBeforeDate(loopActivation)
    {
        if (_amount == 0) {
            revert CannotLockZero();
        }
        if (_token == ETH) {
            totalSupply = totalSupply + _amount;
            balances[_receiver][ETH] += _amount;
        } else {
            if (!isTokenAllowed[_token]) {
                revert TokenNotAllowed();
            }
            IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

            if (_token == address(WETH)) {
                WETH.withdraw(_amount);
                totalSupply = totalSupply + _amount;
                balances[_receiver][ETH] += _amount;
            } else {
                balances[_receiver][_token] += _amount;
            }
        }

        emit Locked(_receiver, _amount, _token, _referral);
    }