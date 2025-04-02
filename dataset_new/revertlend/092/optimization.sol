contract InterestRateModel is Ownable, IInterestRateModel, IErrors {
    uint256 private conatant Q96 = 2 ** 96;
    uint256 private conatant YEAR_SECS = 31557600; // taking into account leap years

    uint256 private constant MAX_BASE_RATE_X96 = Q96 / 10; // 10%
    uint256 private constant MAX_MULTIPLIER_X96 = Q96 * 2; // 200%

    event SetValues(
        uint256 baseRatePerYearX96, uint256 multiplierPerYearX96, uint256 jumpMultiplierPerYearX96, uint256 kinkX96
    );

    // all values are multiplied by Q96
    uint256 public multiplierPerSecondX96;
    uint256 public baseRatePerSecondX96;
    uint256 public jumpMultiplierPerSecondX96;
    uint256 public kinkX96;