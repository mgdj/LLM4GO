function initialize(
    address tokenAddress,
    address _burnAddress,
    address initialAdmin,
    address[] calldata initialSlashers,
    address[] calldata initialReleasers
) public initializer {
    assembly {
        if iszero(tokenAddress) {
            mstore(0x00, 0x08c379a0) // keccak256("Error(string)") selector
            mstore(0x04, 0x20) // offset for the string
            mstore(0x24, 0x13) // length of string "AddressCannotBeZero"
            mstore(0x44, "AddressCannotBeZero") // the error message
            revert(0x00, 0x64) // revert with the error message
        }
    }

    __AccessControl_init();
    __Pausable_init();

    _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
    _grantRole(PAUSER_ROLE, initialAdmin);

    // Grant SLASHER_ROLE to initialSlashers
    uint256 x= initialSlashers.length;
    for (uint256 i = 0; i < x; ) {
      _grantRole(SLASHER_ROLE, initialSlashers[i]);
      unchecked{
        ++i;
      }
    }
    uint256 y = initialReleasers.length;
    for (uint256 i = 0; i < y; ) {
      _grantRole(RELEASER_ROLE, initialReleasers[i]);
      unchecked{
        ++i;
      }
    }

    token = IERC20(tokenAddress);
    burnAddress = _burnAddress;

    currentSlashRound = 1;
    burnRoundMinimumDuration = 90 days;
    lastBurnTimestamp = block.timestamp;
}