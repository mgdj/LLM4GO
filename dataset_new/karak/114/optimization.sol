    function allowlistAssets(address[] calldata assets, address[] calldata slashingHandlers)
        external
        onlyRolesOrOwner(Constants.MANAGER_ROLE)
    {
        _self().allowlistAssets(assets, slashingHandlers);
        emit AllowlistedAssets(assets);
    }