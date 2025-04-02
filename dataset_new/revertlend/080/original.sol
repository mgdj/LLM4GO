// updates collateral token configs - and check if limit is not surpassed (check is only done on increasing debt shares)
function _updateAndCheckCollateral(
    uint256 tokenId,
    uint256 debtExchangeRateX96,
    uint256 lendExchangeRateX96,
    uint256 oldShares,
    uint256 newShares
) internal {
    if (oldShares != newShares) {
        (,, address token0, address token1,,,,,,,,) = nonfungiblePositionManager.positions(tokenId);

        // remove previous collateral - add new collateral
        if (oldShares > newShares) {
            tokenConfigs[token0].totalDebtShares -= SafeCast.toUint192(oldShares - newShares);
            tokenConfigs[token1].totalDebtShares -= SafeCast.toUint192(oldShares - newShares);
        } else {
            tokenConfigs[token0].totalDebtShares += SafeCast.toUint192(newShares - oldShares);
            tokenConfigs[token1].totalDebtShares += SafeCast.toUint192(newShares - oldShares);

            // check if current value of used collateral is more than allowed limit
            // if collateral is decreased - never revert
            uint256 lentAssets = _convertToAssets(totalSupply(), lendExchangeRateX96, Math.Rounding.Up);
            uint256 collateralValueLimitFactorX32 = tokenConfigs[token0].collateralValueLimitFactorX32;
            if (
                collateralValueLimitFactorX32 < type(uint32).max
                    && _convertToAssets(tokenConfigs[token0].totalDebtShares, debtExchangeRateX96, Math.Rounding.Up)
                        > lentAssets * collateralValueLimitFactorX32 / Q32
            ) {
                revert CollateralValueLimit();
            }
            collateralValueLimitFactorX32 = tokenConfigs[token1].collateralValueLimitFactorX32;
            if (
                collateralValueLimitFactorX32 < type(uint32).max
                    && _convertToAssets(tokenConfigs[token1].totalDebtShares, debtExchangeRateX96, Math.Rounding.Up)
                        > lentAssets * collateralValueLimitFactorX32 / Q32
            ) {
                revert CollateralValueLimit();
            }
        }
    }
}