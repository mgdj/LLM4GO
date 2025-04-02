function initialize(address owner, IERC20[] calldata _supportedAssets) external initializer {
        _initializeOwner(owner);
        Config storage config = _config();
        uint256 x = _supportedAssets.length
        for (uint256 i = 0; i < x; ) {
            config.supportedAssets[_supportedAssets[i]] = true;
            unchecked{
                ++i;
            }
        }
    }