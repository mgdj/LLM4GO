contract FighterFarm is ERC721, ERC721Enumerable {

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Event emitted when a fighter is locked and thus cannot be traded.
    event Locked(uint256 tokenId);

    /// @notice Event emitted when a fighter is unlocked and can be traded.
    event Unlocked(uint256 tokenId);

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice The maximum amount of fighters owned by an address.
    uint8 public constant MAX_FIGHTERS_ALLOWED = 10;

    /// @notice The maximum amount of rerolls for each fighter.
    uint8[2] public maxRerollsAllowed = [3, 3];

    /// @notice The cost ($NRN) to reroll a fighter.
    uint256 public rerollCost = 1000 * 10**18;    

    /// @notice Stores the current generation for each fighter type.
    uint8[2] public generation = [0, 0];

    /// @notice Aggregate number of training sessions recorded.
    uint32 public totalNumTrained;

    /// @notice The address of treasury.
    address public treasuryAddress;

    /// The address that has owner privileges (initially the contract deployer).
    address _ownerAddress;

    /// The address responsible for setting token URIs and signing fighter claim messages.
    address _delegatedAddress;

    /// The address of the Merging Pool contract.
    address _mergingPoolAddress;

    /// @dev Instance of the AI Arena Helper contract.
    AiArenaHelper _aiArenaHelperInstance;

    /// @dev Instance of the AI Arena Mintpass contract (ERC721).
    AAMintPass _mintpassInstance;

    /// @dev Instance of the Neuron contract (ERC20).
    Neuron _neuronInstance;

    /// @notice List of all fighter structs, accessible by using tokenId as index.
    FighterOps.Fighter[] public fighters;

    /*//////////////////////////////////////////////////////////////
                                MAPPINGS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping to keep track of whether a tokenId has staked or not.
    mapping(uint256 => bool) public fighterStaked;

    /// @notice Mapping to keep track of how many times an nft has been re-rolled.
    mapping(uint256 => uint8) public numRerolls;

    /// @notice Mapping to indicate which addresses are able to stake fighters.
    mapping(address => bool) public hasStakerRole;

    /// @notice Mapping of number elements by generation.
    mapping(uint8 => uint8) public numElements;

    /// @notice Maps address to fighter type to return the number of NFTs claimed.
    mapping(address => mapping(uint8 => uint8)) public nftsClaimed;

    /// @notice Mapping of tokenId to number of times trained.
    mapping(uint256 => uint32) public numTrained;

    /// @notice Mapping to keep track of tokenIds and their URI.
    mapping(uint256 => string) private _tokenURIs;