function pauseNode(INativeNode node, uint256 map) external payable onlyRolesOrOwner(Constants.MANAGER_ROLE) {
        node.pause(map);
    }