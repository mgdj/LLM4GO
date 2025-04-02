contract AutoCompound is Automator, Multicall, ReentrancyGuard {
    // autocompound event
    event AutoCompounded(
        address account,
        uint256 tokenId,
        uint256 amountAdded0,
        uint256 amountAdded1,
        uint256 reward0,
        uint256 reward1,
        address token0,
        address token1
    );

    // config changes
    event RewardUpdated(address account, uint64 totalRewardX64);

    // balance movements
    event BalanceAdded(uint256 tokenId, address token, uint256 amount);
    event BalanceRemoved(uint256 tokenId, address token, uint256 amount);
    event BalanceWithdrawn(uint256 tokenId, address token, address to, uint256 amount);

    constructor(
        INonfungiblePositionManager _npm,
        address _operator,
        address _withdrawer,
        uint32 _TWAPSeconds,
        uint16 _maxTWAPTickDifference
    ) Automator(_npm, _operator, _withdrawer, _TWAPSeconds, _maxTWAPTickDifference, address(0), address(0)) {}

    mapping(uint256 => mapping(address => uint256)) public positionBalances;

    uint64 public constant MAX_REWARD_X64 = uint64(Q64 / 50); // 2%
    uint64 public totalRewardX64 = MAX_REWARD_X64; // 2%

    /// @notice params for execute()
    struct ExecuteParams {
        // tokenid to autocompound
        uint256 tokenId;
        // swap direction - calculated off-chain
        bool swap0To1;
        // swap amount - calculated off-chain - if this is set to 0 no swap happens
        uint256 amountIn;
    }

    // state used during autocompound execution
    struct ExecuteState {
        uint256 amount0;
        uint256 amount1;
        uint256 maxAddAmount0;
        uint256 maxAddAmount1;
        uint256 amount0Fees;
        uint256 amount1Fees;
        uint256 priceX96;
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 compounded0;
        uint256 compounded1;
        int24 tick;
        uint160 sqrtPriceX96;
        uint256 amountInDelta;
        uint256 amountOutDelta;
    }