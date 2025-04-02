struct TokenConfig {
    AggregatorV3Interface feed; // chainlink feed
    uint32 maxFeedAge;
    uint8 feedDecimals;
    uint8 tokenDecimals;
    IUniswapV3Pool pool; // reference pool
    bool isToken0;
    uint32 twapSeconds;
    Mode mode;
    uint16 maxDifference; // max price difference x10000
}