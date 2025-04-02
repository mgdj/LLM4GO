function callHookIfInterfaceImplemented(
        IERC165 dss,
        bytes memory data,
        bytes4 interfaceId,
        bool ignoreFailure,
        uint32 hookCallGasLimit,
        uint32 supportsInterfaceGasLimit,
        uint32 hookGasBuffer
    ) internal returns (bool) {
        if (gasleft() < (supportsInterfaceGasLimit * 64 / 63 + hookGasBuffer)) {
            revert NotEnoughGas();
        }

        (bool success, bytes32 result) = performLowLevelCallAndLimitReturnData(
            address(dss),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId),
            supportsInterfaceGasLimit
        );

        if (!success || result == bytes32(0)) {
            // Either call failed or interface isn't implemented
            emit InterfaceNotSupported();
            return false;
        }
        return callHook(address(dss), data, ignoreFailure, hookCallGasLimit, hookGasBuffer);
    }