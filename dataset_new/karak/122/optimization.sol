function initialize(
        address _owner,
        address _operator,
        address _depositToken,
        string calldata _name,
        string calldata _symbol,
        bytes calldata _extraData
    ) external initializer {
        _initializeOwner(_owner);
        __Pauser_init();

        (bool decimalsSuccess, uint8 result) = _tryGetAssetDecimals(address(_depositToken));
        VaultLib.Config storage config = _config();

        config.asset = _depositToken;
        config.name = _name;
        config.symbol = _symbol;
        config.decimals = decimalsSuccess ? result : _DEFAULT_UNDERLYING_DECIMALS;
        config.operator = _operator;
        config.extraData = _extraData;
    }