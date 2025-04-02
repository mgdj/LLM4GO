/// @notice Borrows specified amount using token as collateral
/// @param tokenId The token ID to use as collateral
/// @param assets How much assets to borrow
function borrow(uint256 tokenId, uint256 assets) external override {
    bool isTransformMode =
        transformedTokenId > 0 && transformedTokenId == tokenId && transformerAllowList[msg.sender];

    (uint256 newDebtExchangeRateX96, uint256 newLendExchangeRateX96) = _updateGlobalInterest();

    _resetDailyDebtIncreaseLimit(newLendExchangeRateX96, false);

    Loan storage loan = loans[tokenId];

    // if not in transfer mode - must be called from owner or the vault itself
    if (!isTransformMode && tokenOwner[tokenId] != msg.sender && address(this) != msg.sender) {
        revert Unauthorized();
    }

    uint256 shares = _convertToShares(assets, newDebtExchangeRateX96, Math.Rounding.Up);

    uint256 loanDebtShares = loan.debtShares + shares;
    loan.debtShares = loanDebtShares;
    debtSharesTotal += shares;

    if (debtSharesTotal > _convertToShares(globalDebtLimit, newDebtExchangeRateX96, Math.Rounding.Down)) {
        revert GlobalDebtLimit();
    }
    if (assets > dailyDebtIncreaseLimitLeft) {
        revert DailyDebtIncreaseLimit();
    } else {
        dailyDebtIncreaseLimitLeft -= assets;
    }

    _updateAndCheckCollateral(
        tokenId, newDebtExchangeRateX96, newLendExchangeRateX96, loanDebtShares - shares, loanDebtShares
    );

    uint256 debt = _convertToAssets(loanDebtShares, newDebtExchangeRateX96, Math.Rounding.Up);

    if (debt < minLoanSize) {
        revert MinLoanSize();
    }

    // only does check health here if not in transform mode
    if (!isTransformMode) {
        _requireLoanIsHealthy(tokenId, debt);
    }

    address owner = tokenOwner[tokenId];

    // fails if not enough asset available
    // if called from transform mode - send funds to transformer contract
    SafeERC20.safeTransfer(IERC20(asset), isTransformMode ? msg.sender : owner, assets);

    emit Borrow(tokenId, owner, assets, shares);
}