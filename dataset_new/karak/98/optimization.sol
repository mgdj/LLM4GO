function changeNodeImplementation(address newNodeImplementation)
    external
    onlyOwnerOrRoles(Constants.MANAGER_ROLE)
    whenFunctionNotPaused(Constants.PAUSE_NATIVEVAULT_NODE_IMPLEMENTATION)
{
    assembly {
        if iszero(newNodeImplementation) {
            mstore(0x00, 0x4e487b71) // Custom error selector for ZeroAddress()
            revert(0x00, 0x04)
        }
    }

    _state().nodeImpl = newNodeImplementation;
    emit UpgradedAllNodes(newNodeImplementation);
}