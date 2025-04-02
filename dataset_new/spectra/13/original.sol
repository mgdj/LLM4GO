function flashLoan(
        IERC3156FlashBorrower _receiver,
        address _token,
        uint256 _amount,
        bytes calldata _data
    ) external override returns (bool) {
        if (_amount > maxFlashLoan(_token)) revert FlashLoanExceedsMaxAmount();

        uint256 fee = flashFee(_token, _amount);
        _updateFees(fee);

        // Initiate the flash loan by lending the requested IBT amount
        IERC20(ibt).safeTransfer(address(_receiver), _amount);

        // Execute the flash loan
        if (_receiver.onFlashLoan(msg.sender, _token, _amount, fee, _data) != ON_FLASH_LOAN)
            revert FlashLoanCallbackFailed();

        // Repay the debt + fee
        IERC20(ibt).safeTransferFrom(address(_receiver), address(this), _amount + fee);

        return true;
    }