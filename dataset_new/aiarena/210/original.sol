contract VoltageManager {

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Event emitted when voltage amount is altered.
    event VoltageRemaining(address spender, uint8 voltage);  

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// The address that has owner privileges (initially the contract deployer).
    address _ownerAddress;
    
    /// @dev The game items contract instance.
    GameItems _gameItemsContractInstance;

    /*//////////////////////////////////////////////////////////////
                                MAPPINGS
    //////////////////////////////////////////////////////////////*/

    /// @notice Maps the address to the allowed voltage spenders.
    mapping(address => bool) public allowedVoltageSpenders;

    /// @notice Maps the address to the voltage replenish time.
    mapping(address => uint32) public ownerVoltageReplenishTime;

    /// @notice Maps the address to the voltage.
    mapping(address => uint8) public ownerVoltage;

    /// @notice Mapping of address to admin status.
    mapping(address => bool) public isAdmin;