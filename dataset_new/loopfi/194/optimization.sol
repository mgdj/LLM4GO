contract PrelaunchPoints {
    using Math for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for ILpETH;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    uint256 public totalSupply;
    uint256 public totalLpETH;
    mapping(address => bool) public isTokenAllowed;

    mapping(address => mapping(address => uint256)) public balances; // User -> Token -> Balance

    address public owner;    
    ILpETH public lpETH;
    ILpETHVault public lpETHVault;

    uint32 public loopActivation;
    uint32 public startClaimDate;
    uint32 public constant TIMELOCK = 7 days;
    bool public emergencyMode;

    IWETH public immutable WETH;
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable exchangeProxy;


    

    enum Exchange {
        UniswapV3,
        TransformERC20
    }

    bytes4 public constant UNI_SELECTOR = 0x803ba26d;
    bytes4 public constant TRANSFORM_SELECTOR = 0x415565b0;

