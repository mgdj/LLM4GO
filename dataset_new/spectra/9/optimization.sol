function initialize(
        address _ibt,
        uint256 _duration,
        address _initialAuthority
    ) external initializer {
        if (_ibt == address(0) || _initialAuthority == address(0)) {
            revert AddressError();
        }
        if (IERC4626(_ibt).totalAssets() == 0) {
            revert RateError();
        }
        _asset = IERC4626(_ibt).asset();
        duration = _duration;
        expiry = _duration + block.timestamp;
        string memory _ibtSymbol = IERC4626(_ibt).symbol();
        uint256 _expiry = expiry;
        string memory name = NamingUtil.genPTName(_ibtSymbol, _expiry);
        __ERC20_init(name, NamingUtil.genPTSymbol(_ibtSymbol, _expiry));
        __ERC20Permit_init(name);
        __Pausable_init();
        __ReentrancyGuard_init();
        __AccessManaged_init(_initialAuthority);
        _ibtDecimals = IERC4626(_ibt).decimals();
        _assetDecimals = PrincipalTokenUtil._tryGetTokenDecimals(_asset);
        if (
            _assetDecimals < MIN_DECIMALS ||
            _assetDecimals > _ibtDecimals ||
            _ibtDecimals > MAX_DECIMALS
        ) {
            revert InvalidDecimals();
        }
        ibt = _ibt;
        ibtUnit = 10 ** _ibtDecimals;
        ibtRate = IERC4626(ibt).previewRedeem(ibtUnit).toRay(_assetDecimals);
        ptRate = RayMath.RAY_UNIT;
        yt = _deployYT(
            NamingUtil.genYTName(_ibtSymbol, _expiry),
            NamingUtil.genYTSymbol(_ibtSymbol, _expiry)
        );
    }