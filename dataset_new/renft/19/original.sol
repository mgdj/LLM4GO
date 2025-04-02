contract StorageBase {

    mapping(bytes32 orderHash => bool isActive) public orders;

    mapping(RentalId itemId => uint256 amount) public rentedAssets;

    mapping(address safe => uint256 nonce) public deployedSafes;

    // Records the total amount of deployed safes.
    uint256 public totalSafes;

    mapping(address to => address hook) internal _contractToHook;

    // Mapping of a bitmap which denotes the hook functions that are enabled.
    mapping(address hook => uint8 enabled) public hookStatus;

    mapping(address delegate => bool isWhitelisted) public whitelistedDelegates;

    // Allows for the safe registration of extensions that can be enabled on a safe.
    mapping(address extension => bool isWhitelisted) public whitelistedExtensions;