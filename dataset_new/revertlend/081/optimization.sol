contract AutoExit is Automator {
    event Executed(
        uint256 indexed tokenId,
        address account,
        bool isSwap,
        uint256 amountReturned0,
        uint256 amountReturned1,
        address token0,
        address token1
    );
    event PositionConfigured(
        uint256 indexed tokenId,
        bool isActive,
        bool token0Swap,
        bool token1Swap,
        int24 token0TriggerTick,
        int24 token1TriggerTick,
        uint64 token0SlippageX64,
        uint64 token1SlippageX64,
        bool onlyFees,
        uint64 maxRewardX64
    );

    constructor(
        INonfungiblePositionManager _npm,
        address _operator,
        address _withdrawer,
        uint32 _TWAPSeconds,
        uint16 _maxTWAPTickDifference,
        address _zeroxRouter,
        address _universalRouter
    ) Automator(_npm, _operator, _withdrawer, _TWAPSeconds, _maxTWAPTickDifference, _zeroxRouter, _universalRouter) {}

    // define how stoploss / limit should be handled
    struct PositionConfig {
        bool isActive; // if position is active
        // should swap token to other token when triggered
        bool token0Swap;
        bool token1Swap;
        // when should action be triggered (when this tick is reached - allow execute)
        int24 token0TriggerTick; // when tick is below this one
        int24 token1TriggerTick; // when tick is equal or above this one
        // max price difference from current pool price for swap / Q64
        uint64 token0SlippageX64; // when token 0 is swapped to token 1
        uint64 token1SlippageX64; // when token 1 is swapped to token 0
        bool onlyFees; // if only fees maybe used for protocol reward
        uint64 maxRewardX64; // max allowed reward percentage of fees or full position
    }

    // configured tokens
    mapping(uint256 => PositionConfig) public positionConfigs;
    struct ExecuteParams {
        uint256 tokenId; // tokenid to process
        bytes swapData; // if its a swap order - must include swap data
        uint256 amountRemoveMin0; // min amount to be removed from liquidity
        uint256 amountRemoveMin1; // min amount to be removed from liquidity
        uint64 deadline; // for uniswap operations - operator promises fair value
        uint64 rewardX64; // which reward will be used for protocol, can be max configured amount (considering onlyFees)
        uint128 liquidity; // liquidity the calculations are based on
    }