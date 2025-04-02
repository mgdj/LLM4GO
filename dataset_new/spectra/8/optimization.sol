contract PrincipalToken is
    ERC20PermitUpgradeable,
    AccessManagedUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    IPrincipalToken
{
    using SafeERC20 for IERC20;
    using RayMath for uint256;
    using Math for uint256;

    uint256 private constant MIN_DECIMALS = 6;
    uint256 private constant MAX_DECIMALS = 18;
    bytes32 private constant ON_FLASH_LOAN = keccak256("ERC3156FlashBorrower.onFlashLoan");

    address private immutable registry;

    address private rewardsProxy;
    uint256 private ratesAtExpiryStored;
    address private ibt; // address of the Interest Bearing Token 4626 held by this PT vault
    address private _asset; // the asset of this PT vault (which is also the asset of the IBT 4626)
    address private yt; // YT corresponding to this PT, deployed at initialization
    uint256 private ibtUnit; // equal to one unit of the IBT held by this PT vault (10^decimals)
    uint256 private _ibtDecimals;
    uint256 private _assetDecimals;

    uint256 private ptRate; // or PT price in asset (in Ray)
    uint256 private ibtRate; // or IBT price in asset (in Ray)
    uint256 private unclaimedFeesInIBT; // unclaimed fees
    uint256 private totalFeesInIBT; // total fees
    uint256 private expiry; // date of maturity (set at initialization)
    uint256 private duration; // duration to maturity

    mapping(address => uint256) private ibtRateOfUser; // stores each user's IBT rate (in Ray)
    mapping(address => uint256) private ptRateOfUser; // stores each user's PT rate (in Ray)
    mapping(address => uint256) private yieldOfUserInIBT; // stores each user's yield generated from YTs