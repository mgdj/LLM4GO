    function withdraw(address _token) external {
        if (!emergencyMode) {
            if (block.timestamp <= loopActivation) {
                revert CurrentlyNotPossible();
            }
            if (block.timestamp >= startClaimDate) {
                revert NoLongerPossible();
            }
        }

        uint256 lockedAmount = balances[msg.sender][_token];
        balances[msg.sender][_token] = 0;

        if (lockedAmount == 0) {
            revert CannotWithdrawZero();
        }
        if (_token == ETH) {
            if (block.timestamp >= startClaimDate){
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