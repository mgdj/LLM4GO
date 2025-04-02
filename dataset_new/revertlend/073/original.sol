contract V3Oracle is IV3Oracle, Ownable, IErrors {
    uint16 public constant MIN_PRICE_DIFFERENCE = 200; //2%

    uint256 private constant Q96 = 2 ** 96;
    uint256 private constant Q128 = 2 ** 128;

    event TokenConfigUpdated(address indexed token, TokenConfig config);
    event OracleModeUpdated(address indexed token, Mode mode);
    event SetMaxPoolPriceDifference(uint16 maxPoolPriceDifference);
    event SetEmergencyAdmin(address emergencyAdmin);

    enum Mode {
        NOT_SET,
        CHAINLINK_TWAP_VERIFY, // using chainlink for price and TWAP to verify
        TWAP_CHAINLINK_VERIFY, // using TWAP for price and chainlink to verify
        CHAINLINK, // using only chainlink directly
        TWAP // using TWAP directly
    }

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

    // token => config mapping
    mapping(address => TokenConfig) public feedConfigs;

    address public immutable factory;
    INonfungiblePositionManager public immutable nonfungiblePositionManager;

    // common token which is used in TWAP pools
    address public immutable referenceToken;
    uint8 public immutable referenceTokenDecimals;

    uint16 public maxPoolPriceDifference = MIN_PRICE_DIFFERENCE; // max price difference between oracle derived price and pool price x10000

    // common token which is used in chainlink feeds as "pair" (address(0) if USD or another non-token reference)
    address public immutable chainlinkReferenceToken;

    // address which can call special emergency actions without timelock
    address public emergencyAdmin;