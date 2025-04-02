contract MergingPool {

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Event emitted when merging pool points are added.
    event PointsAdded(uint256 tokenId, uint256 points);

    /// @notice Event emitted when claimed.
    event Claimed(address claimer, uint32 amount);

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Number of winners per period.
    uint256 public winnersPerPeriod = 2;

    /// @notice Current roundId.
    uint256 public roundId = 0;

    /// @notice Total points.
    uint256 public totalPoints = 0;    

    /// The address that has owner privileges (initially the contract deployer).
    address _ownerAddress;

    /// The address of the ranked battle contract.
    address _rankedBattleAddress;

    /// @dev The fighter farm contract instance.
    FighterFarm _fighterFarmInstance;

    /*//////////////////////////////////////////////////////////////
                                MAPPINGS
    //////////////////////////////////////////////////////////////*/

    /// @notice Maps the user address to the number of rounds they've claimed for
    mapping(address => uint32) public numRoundsClaimed;

    /// @notice Mapping of address to fighter points.
    mapping(uint256 => uint256) public fighterPoints;

    /// @notice Mapping of roundId to winner addresses list.
    mapping(uint256 => address[]) public winnerAddresses;    

    /// @notice Mapping of round id to an indication of whether winners have been selected yet.
    mapping(uint256 => uint256) public isSelectionComplete;

    /// @notice Mapping of address to admin status.
    mapping(address => uint256) public isAdmin;