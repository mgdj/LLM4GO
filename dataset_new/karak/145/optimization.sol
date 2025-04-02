function callHook(
        address target,
        bytes memory data,
        bool ignoreFailure,
        uint32 hookCallGasLimit,
        uint32 hookGasBuffer
    ) internal returns (bool) {
        if (gasleft() < (hookCallGasLimit << 6 / 63 + hookGasBuffer)) revert NotEnoughGas();

        (bool success, bytes32 returnData) = performLowLevelCallAndLimitReturnData(target, data, hookCallGasLimit);

        if (!ignoreFailure && !success) revert DSSHookCallReverted(returnData);

        if (success) emit HookCallSucceeded(returnData);
        else emit HookCallFailed(returnData);
        return success;
    }