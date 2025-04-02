contract IdentityStaking is
  IIdentityStaking,
  Initializable,
  UUPSUpgradeable,
  AccessControlUpgradeable,
  PausableUpgradeable
{
  /***** SECTION 0: Errors, State, Events *****/

  /// @dev Address parameter cannot be zero
  error AddressCannotBeZero();

  /// @dev Stake amount must be greater than zero
  error AmountMustBeGreaterThanZero();

  /// @dev A community stake cannot be placed on the staker's own address
  error CannotStakeOnSelf();

  /// @dev An ERC20 transfer failed
  error FailedTransfer();

  /// @dev The lock time must be between 12 and 104 weeks, and after any existing lock
  error InvalidLockTime();

  /// @dev The stake is still locked and cannot be withdrawn
  error StakeIsLocked();

  /// @dev The requested withdrawal amount is greater than the stake
  error AmountTooHigh();

  /// @dev The slash percent must be between 1 and 100
  error InvalidSlashPercent();

  /// @dev The staker and stakee arrays must be the same length
  error StakerStakeeMismatch();

  /// @dev The requested funds are greater than the slashed amount for this user
  error FundsNotAvailableToRelease();

  /// @dev The requested funds are not available to release for this user from the given round
  error FundsNotAvailableToReleaseFromRound();

  /// @dev The round has already been burned and its slashed stake cannot be released
  error RoundAlreadyBurned();

  /// @dev The minimum burn round duration has not been met, controlled by the `burnRoundMinimumDuration`
  error MinimumBurnRoundDurationNotMet();

  /// @notice Role held by addresses which are permitted to submit a slash.
  bytes32 public constant SLASHER_ROLE = keccak256("SLASHER_ROLE");

  /// @notice Role held by addresses which are permitted to release an un-burned slash.
  bytes32 public constant RELEASER_ROLE = keccak256("RELEASER_ROLE");

  /// @notice Role held by addresses which are permitted to pause the contract.
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  /// @notice Struct representing a stake
  /// @param unlockTime The unix time in seconds after which the stake can be withdrawn
  /// @param amount The amount of GTC staked, with 18 decimals
  /// @param slashedAmount The amount of GTC slashed (could already be burned)
  /// @param slashedInRound The round in which the stake was last slashed
  /// @dev uint88s can hold up to 300 million w/ 18 decimals, or 3x the current max supply
  ///      `amount` does not include any slashed or burned GTC
  struct Stake {
    uint64 unlockTime;
    uint88 amount;
    uint88 slashedAmount;
    uint16 slashedInRound;
  }

  /// @inheritdoc IIdentityStaking
  mapping(address => uint88) public userTotalStaked;

  /// @inheritdoc IIdentityStaking
  mapping(address => Stake) public selfStakes;

  /// @inheritdoc IIdentityStaking
  mapping(address => mapping(address => Stake)) public communityStakes;

  /// @notice The current round of slashing, incremented on each call to `lockAndBurn`
  /// @dev uint16 can hold up to 65,535 rounds, or 16,383 years with 90 day rounds
  ///      Set to `1` in the initializer
  uint16 public currentSlashRound;

  /// @notice The minimum duration between burn rounds
  /// @dev This sets the minimum appeal period for a slash
  ///      Set to `90 days` in the initializer
  uint64 public burnRoundMinimumDuration;

  /// @notice The timestamp of the last burn
  uint256 public lastBurnTimestamp;

  /// @notice The address to which all burned tokens are sent
  /// @dev Set in the initializer
  ///      This could be set to the zero address. But in the case of GTC,
  ///      it is set to the GTC token contract address because GTC cannot
  ///      be transferred to the zero address
  address public burnAddress;

  /// @notice The total amount of GTC slashed in each round
  mapping(uint16 => uint88) public totalSlashed;

  /// @notice The GTC token contract
  IERC20 public token;

  /// @notice Emitted when a self-stake is added/increased/extended
  /// @param staker The staker's address
  /// @param amount The additional amount added for this particular transaction
  /// @param unlockTime Unlock time for the full self-stake amount for this staker
  /// @dev `amount` could be `0` for an extension
  event SelfStake(address indexed staker, uint88 amount, uint64 unlockTime);

  /// @notice Emitted when a community stake is added/increased/extended
  /// @param staker The staker's address
  /// @param stakee The stakee's address
  /// @param amount The additional amount added for this particular transaction
  /// @param unlockTime Unlock time for the full community stake amount for this staker on this stakee
  /// @dev `amount` could be `0` for an extension
  event CommunityStake(
    address indexed staker,
    address indexed stakee,
    uint88 amount,
    uint64 unlockTime
  );

  /// @notice Emitted when a self-stake is withdrawn
  /// @param staker The staker's address
  /// @param amount The amount withdrawn in this transaction
  event SelfStakeWithdrawn(address indexed staker, uint88 amount);

  /// @notice Emitted when a community stake is withdrawn
  /// @param staker The staker's address
  /// @param stakee The stakee's address
  /// @param amount The amount withdrawn in this transaction
  event CommunityStakeWithdrawn(address indexed staker, address indexed stakee, uint88 amount);

  /// @notice Emitted when a slash is submitted
  /// @param staker Address of the staker who is slashed
  /// @param amount The amount slashed in this transaction
  /// @param round The round in which the slash occurred
  event Slash(address indexed staker, uint88 amount, uint16 round);

  /// @notice Emitted when a round is burned
  /// @param round The round that was burned
  /// @param amount The amount of GTC burned in this transaction
  event Burn(uint16 indexed round, uint88 amount);