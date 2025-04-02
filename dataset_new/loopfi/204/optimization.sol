contract PrelaunchPoints {
    using Math for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for ILpETH;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    ILpETH public lpETH;
    ILpETHVault public lpETHVault;
    IWETH public immutable WETH;
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable exchangeProxy;

    address public owner;

    uint256 public totalSupply;
    uint256 public totalLpETH;
    mapping(address => bool) public isTokenAllowed;

    enum Exchange {
        UniswapV3,
        TransformERC20
    }

    bytes4 private constant UNI_SELECTOR = 0x803ba26d;
    bytes4 private constant TRANSFORM_SELECTOR = 0x415565b0;

    uint32 public loopActivation;
    uint32 public startClaimDate;
    uint32 private constant TIMELOCK = 7 days;
    bool public emergencyMode;

    mapping(address => mapping(address => uint256)) public balances; // User -> Token -> Balance