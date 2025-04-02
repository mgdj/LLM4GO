contract Core is IBeacon, ICore, OwnableRoles, Initializable, ReentrancyGuard, Pauser, ExtSloads {
    using CoreLib for CoreLib.Storage;
    using Operator for CoreLib.Storage;
    using Operator for Operator.State;
    using SlasherLib for SlasherLib.QueuedSlashing;
    using SlasherLib for SlasherLib.SlashRequest;
    using SlasherLib for CoreLib.Storage;
    using VaultLib for VaultLib.Config;
    using CommonUtils for address;

    string private constant VERSION = "2.0.0";

    // keccak256(abi.encode(uint256(keccak256("core.storage")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 internal constant STORAGE_SLOT = 0x13c729cff436dc8ac22d145f2c778f6a709d225083f39538cc5e2674f2f10700;
