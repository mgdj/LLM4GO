function _calculateGlobalInterest()
    internal
    view
    returns (uint256 newDebtExchangeRateX96, uint256 newLendExchangeRateX96)
{
    uint256 oldDebtExchangeRateX96 = lastDebtExchangeRateX96;
    uint256 oldLendExchangeRateX96 = lastLendExchangeRateX96;

    (, uint256 available,) = _getAvailableBalance(oldDebtExchangeRateX96, oldLendExchangeRateX96);

    uint256 debt = _convertToAssets(debtSharesTotal, oldDebtExchangeRateX96, Math.Rounding.Up);

    (uint256 borrowRateX96, uint256 supplyRateX96) = interestRateModel.getRatesPerSecondX96(available, debt);

    supplyRateX96 = supplyRateX96.mulDiv(Q32 - reserveFactorX32, Q32);

    // always growing or equal
    uint256 lastRateUpdate = lastExchangeRateUpdate;
    uint256 block.timestampSUBlastRateUpdate = block.timestamp - lastRateUpdate;
    if (lastRateUpdate > 0) {
        newDebtExchangeRateX96 = oldDebtExchangeRateX96
            + oldDebtExchangeRateX96 * block.timestampSUBlastRateUpdate * borrowRateX96 / Q96;
        newLendExchangeRateX96 = oldLendExchangeRateX96
            + oldLendExchangeRateX96 * block.timestampSUBlastRateUpdate * supplyRateX96 / Q96;
    } else {
        newDebtExchangeRateX96 = oldDebtExchangeRateX96;
        newLendExchangeRateX96 = oldLendExchangeRateX96;
    }
}