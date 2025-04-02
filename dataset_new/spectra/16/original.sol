function _deployYT(string memory _name, string memory _symbol) internal returns (address _yt) {
        address ytBeacon = IRegistry(registry).getYTBeacon();
        if (ytBeacon == address(0)) {
            revert BeaconNotSet();
        }
        _yt = address(
            new BeaconProxy(
                ytBeacon,
                abi.encodeWithSelector(
                    IYieldToken(address(0)).initialize.selector,
                    _name,
                    _symbol,
                    address(this)
                )
            )
        );
        emit YTDeployed(_yt);
    }