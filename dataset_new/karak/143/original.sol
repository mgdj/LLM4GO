contract Vault is ERC4626, Initializable, Ownable, Pauser, ReentrancyGuard, ExtSloads, IVault {
    using VaultLib for VaultLib.State;

    string public constant VERSION = "2.0.0";

    // keccak256(abi.encode(uint256(keccak256("vault.state")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 internal constant STATE_SLOT = 0x5d654853f9da5c5c659891e7f7fc564033f2724663c32c175f373318f8e1e700;
    // keccak256(abi.encode(uint256(keccak256("vault.config")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 internal constant CONFIG_SLOT = 0x22a8eb0cbcfbbbc874f794ecd9efdfeeecb09fe60d66cf9327db2eac8a1ff000;