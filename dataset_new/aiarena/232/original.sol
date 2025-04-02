contract Neuron is ERC20, AccessControl {

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Event emitted when tokens are claimed.
    event TokensClaimed(address user, uint256 amount);

    /// @notice Event emitted when tokens are minted.
    event TokensMinted(address user, uint256 amount);    

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Role for minting tokens.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Role for spending tokens.
    bytes32 public constant SPENDER_ROLE = keccak256("SPENDER_ROLE");
    
    /// @notice Role for staking tokens.
    bytes32 public constant STAKER_ROLE = keccak256("STAKER_ROLE");

    /// @notice Initial supply of NRN tokens to be minted to the treasury.
    uint256 public constant INITIAL_TREASURY_MINT = 10**18 * 10**8 * 2;

    /// @notice Initial supply of NRN tokens to be minted and distributed to contributors.
    uint256 public constant INITIAL_CONTRIBUTOR_MINT = 10**18 * 10**8 * 5;

    /// @notice Maximum supply of NRN tokens.
    uint256 public constant MAX_SUPPLY = 10**18 * 10**9;

    /// @notice The address of treasury.
    address public treasuryAddress;

    /// The address that has owner privileges (initially the contract deployer).
    address _ownerAddress;

    /*//////////////////////////////////////////////////////////////
                                MAPPINGS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping of address to admin status.
    mapping(address => bool) public isAdmin;