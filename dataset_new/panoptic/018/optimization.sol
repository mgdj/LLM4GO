contract SemiFungiblePositionManager is ERC1155, Multicall {
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a UniswapV3Pool is initialized.
    /// @param uniswapPool Address of the underlying Uniswap v3 pool
    event PoolInitialized(address indexed uniswapPool);

    /// @notice Emitted when a position is destroyed/burned
    /// @dev Recipient is used to track whether it was burned directly by the user or through an option contract
    /// @param recipient The address of the user who burned the position
    /// @param tokenId The tokenId of the burned position
    /// @param positionSize The number of contracts burnt, expressed in terms of the asset
    event TokenizedPositionBurnt(
        address indexed recipient,
        uint256 indexed tokenId,
        uint128 positionSize
    );

    /// @notice Emitted when a position is created/minted
    /// @dev Recipient is used to track whether it was minted directly by the user or through an option contract
    /// @param caller the caller who created the position. In 99% of cases `caller` == `recipient`.
    /// @param tokenId The tokenId of the minted position
    /// @param positionSize The number of contracts minted, expressed in terms of the asset
    event TokenizedPositionMinted(
        address indexed caller,
        uint256 indexed tokenId,
        uint128 positionSize
    );

    /*//////////////////////////////////////////////////////////////
                                TYPES 
    //////////////////////////////////////////////////////////////*/

    /// @dev Uses the LeftRight packaging methods for uint256/int256 to store 128bit values
    using LeftRight for int256;
    using LeftRight for uint256;

    using TokenId for uint256; // an option position
    using LiquidityChunk for uint256; // a leg within an option position `tokenId`

    // Packs the pool address and reentrancy lock into a single slot
    // `locked` can be initialized to false because the pool address makes the slot nonzero
    // false = unlocked, true = locked
    struct PoolAddressAndLock {
        IUniswapV3Pool pool;
        uint256 locked;
    }

    /*//////////////////////////////////////////////////////////////
                            IMMUTABLES 
    //////////////////////////////////////////////////////////////*/

    /// @dev flag for mint/burn
    uint256 internal constant MINT = false;
    uint256 internal constant BURN = true;