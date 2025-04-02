    function pause(uint256 map) external onlyRolesOrOwner(Constants.MANAGER_ROLE) {
        _pause(map);
    }