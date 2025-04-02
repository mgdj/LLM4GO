function skim(address token, address to) external onlyByProxy payable permissioned {
        // Fetch the currently synced balance of the escrow.
        uint256 syncedBalance = balanceOf[token];

        // Fetch the true token balance of the escrow.
        uint256 trueBalance = IERC20(token).balanceOf(address(this));

        // Calculate the amount to skim.
        uint256 skimmedBalance = trueBalance - syncedBalance;

        // Send the difference to the specified address.
        _safeTransfer(token, to, skimmedBalance);

        // Emit event with fees taken.
        emit Events.FeeTaken(token, skimmedBalance);
    }
