    function allowlistAssets(address[] memory assets, address[] memory slashingHandlers)
        external
        onlyRolesOrOwner(Constants.MANAGER_ROLE)
    {
        _self().allowlistAssets(assets, slashingHandlers);
        emit AllowlistedAssets(assets);
    }