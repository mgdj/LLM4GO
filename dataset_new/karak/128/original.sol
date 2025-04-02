function pauseNode(INativeNode node, uint256 map) external onlyRolesOrOwner(Constants.MANAGER_ROLE) {
        node.pause(map);
    }