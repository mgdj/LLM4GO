contract GameItems is ERC1155 {

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Event emitted when a game item is bought.
    /// @param buyer The address of the buyer.
    /// @param tokenId The id of the game item.
    /// @param quantity The quantity of the game item.
    event BoughtItem(address buyer, uint256 tokenId, uint256 quantity);

    /// @notice Event emitted when an item is locked and thus cannot be traded.
    /// @param tokenId The id of the game item.
    event Locked(uint256 tokenId);

    /// @notice Event emitted when an item is unlocked and can be traded.
    /// @param tokenId The id of the game item.
    event Unlocked(uint256 tokenId);

    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Struct for game item attributes
    struct GameItemAttributes {
        string name;
        bool finiteSupply;
        bool transferable;
        uint256 itemsRemaining;
        uint256 itemPrice;
        uint256 dailyAllowance;
    }  

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice The name of this smart contract.
    string public name = "AI Arena Game Items";

    /// @notice The symbol for this smart contract.
    string public symbol = "AGI";

    /// @notice List of all gameItemAttribute structs representing all game items.
    GameItemAttributes[] public allGameItemAttributes;

    /// @notice The address that recieves funds of purchased game items.
    address public treasuryAddress;

    /// The address that has owner privileges (initially the contract deployer).
    address _ownerAddress;

    /// Total number of game items.
    uint256 _itemCount = 0;    

    /// @dev The Neuron contract instance.
    Neuron _neuronInstance;
    
    /*//////////////////////////////////////////////////////////////
                                MAPPINGS
    //////////////////////////////////////////////////////////////*/ 

    /// @notice Mapping of address to tokenId to get remaining allowance.
    mapping(address => mapping(uint256 => uint256)) public allowanceRemaining;

    /// @notice Mapping of address to tokenId to get replenish timestamp.
    mapping(address => mapping(uint256 => uint256)) public dailyAllowanceReplenishTime;

    /// @notice Mapping tracking addresses allowed to burn game items.
    mapping(address => uint256) public allowedBurningAddresses;

    /// @notice Mapping tracking addresses allowed to manage game items.
    mapping(address => uint256) public isAdmin;

    /// @notice Mapping of token id to the token URI
    mapping(uint256 => string) private _tokenURIs;