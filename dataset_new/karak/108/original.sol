    function initialize(address owner, IERC20[] calldata _supportedAssets) external initializer {
        _initializeOwner(owner);
        Config storage config = _config();
        for (uint256 i = 0; i < _supportedAssets.length; i++) {
            config.supportedAssets[_supportedAssets[i]] = true;
        }
    }