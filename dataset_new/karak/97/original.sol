    function isAssetAllowlisted(address asset) public view returns (bool) {
        return _self().assetSlashingHandlers[asset] != address(0);
    }