    function changeNodeImplementation(address newNodeImplementation)
        external
        onlyOwnerOrRoles(Constants.MANAGER_ROLE)
        whenFunctionNotPaused(Constants.PAUSE_NATIVEVAULT_NODE_IMPLEMENTATION)
    {
        if (newNodeImplementation == address(0)) revert ZeroAddress();

        _state().nodeImpl = newNodeImplementation;
        emit UpgradedAllNodes(newNodeImplementation);
    }