function isAssetAllowlisted(address asset) public view returns (bool) {
    address handler = _self().assetSlashingHandlers[asset];
    bool isAllowlisted;
    assembly {
        isAllowlisted := iszero(iszero(handler))
    }
    return isAllowlisted;
}