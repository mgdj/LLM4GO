    function withdraw(address _token) external {
        uint256 bts = block.timestamp
        if (!emergencyMode) {
            if (bts <= loopActivation) {
                revert CurrentlyNotPossible();
            }
            if (bts >= startClaimDate) {
                revert NoLongerPossible();
            }
        }

        uint256 lockedAmount = balances[msg.sender][_token];
        balances[msg.sender][_token] = 0;

        if (lockedAmount == 0) {
            revert CannotWithdrawZero();
        }
        if (_token == ETH) {
            if (bts >= startClaimDate){
                revert UseClaimInstead();
            }
            totalSupply = totalSupply - lockedAmount;

            (bool sent,) = msg.sender.call{value: lockedAmount}("");

            if (!sent) {
                revert FailedToSendEther();
            }
        } else {
            IERC20(_token).safeTransfer(msg.sender, lockedAmount);
        }

        emit Withdrawn(msg.sender, _token, lockedAmount);
    }