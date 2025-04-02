function cancelSlashing(CoreLib.Storage storage self, QueuedSlashing calldata queuedSlashing) external {
        bytes32 slashRoot = calculateRoot(queuedSlashing);
        if (!self.slashingRequests[slashRoot]) revert InvalidSlashingParams();
        delete self.slashingRequests[slashRoot];
        IDSS dss = queuedSlashing.dss;

        HookLib.callHookIfInterfaceImplemented({
            dss: dss,
            data: abi.encodeWithSelector(dss.cancelSlashingHook.selector, queuedSlashing.operator),
            interfaceId: dss.cancelSlashingHook.selector,
            ignoreFailure: true,
            hookCallGasLimit: self.hookCallGasLimit,
            supportsInterfaceGasLimit: self.supportsInterfaceGasLimit,
            hookGasBuffer: self.hookGasBuffer
        });
    }