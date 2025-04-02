contract SlashingHandler is Initializable, Ownable, ISlashingHandler {
    string private constant VERSION = "2.0.0";

    // keccak256(abi.encode(uint256(keccak256("slashinghandler.config")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 internal constant CONFIG_SLOT = 0x661dfff6e6cdad10b44554a6ab58129a188fa46a74caae866b07c414cb424500;

    struct Config {
        mapping(IERC20 asset => bool) supportedAssets;
    }