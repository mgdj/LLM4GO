function initialize(
    address _owner,
    address _operator,
    address _depositToken,
    string memory _name,
    string memory _symbol,
    bytes memory _extraData
) external initializer {
    _initializeOwner(_owner);
    __Pauser_init();

    if (_depositToken != Constants.DEAD_BEEF) revert DepositTokenNotAccepted();

    (address manager, address slashStore, address nodeImplementation) =
        abi.decode(_extraData, (address, address, address));

    // Assembly block for checking if manager, slashStore, or nodeImplementation are address(0)
    assembly {
        if or(or(iszero(manager), iszero(slashStore)), iszero(nodeImplementation)) {
            mstore(0x00, 0x4e487b71) // Custom error selector for ZeroAddress()
            revert(0x00, 0x04)
        }
    }

    _grantRoles(manager, Constants.MANAGER_ROLE);

    NativeVaultLib.Storage storage self = _state();
    VaultLib.Config storage config = _config();

    config.asset = _depositToken;
    config.name = _name;
    config.symbol = _symbol;
    config.decimals = 18;
    config.operator = _operator;
    config.extraData = _extraData;

    self.slashStore = slashStore;
    self.nodeImpl = nodeImplementation;

    emit NativeVaultInitialized(_owner, manager, _operator, slashStore);
}