function withdraw(address _token) external {
    uint256 lockedAmount = balances[msg.sender][_token];

    // Use assembly to check for zero balance
    assembly {
        if iszero(lockedAmount) {
            mstore(0x00, 0x4e487b71) // Function selector for custom errors
            revert(0x00, 0x04)
        }
    }

    // Reset balance to 0 before performing any further operations
    balances[msg.sender][_token] = 0;

    if (!emergencyMode) {
        if (block.timestamp <= loopActivation) {
            revert CurrentlyNotPossible();
        }
        if (block.timestamp >= startClaimDate) {
            revert NoLongerPossible();
        }
    }

    if (_token == ETH) {
        if (block.timestamp >= startClaimDate) {
            revert UseClaimInstead();
        }

        totalSupply -= lockedAmount; // Update total supply

        // Use assembly for safe transfer of Ether
        assembly {
            let success := call(gas(), msg.sender, lockedAmount, 0, 0, 0, 0)
            if iszero(success) {
                mstore(0x00, 0x4e487b71) // Function selector for FailedToSendEther()
                revert(0x00, 0x04)
            }
        }
    } else {
        // For ERC20 token transfer, use safeTransfer
        IERC20(_token).safeTransfer(msg.sender, lockedAmount);
    }

    // Emit event after successful withdrawal
    emit Withdrawn(msg.sender, _token, lockedAmount);
}