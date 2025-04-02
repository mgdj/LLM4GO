function finalizeSlashing(CoreLib.Storage storage self, QueuedSlashing memory queuedSlashing) external {
        bytes32 slashRoot = calculateRoot(queuedSlashing);
        if (!self.slashingRequests[slashRoot]) revert InvalidSlashingParams();
        if (queuedSlashing.timestamp + Constants.SLASHING_VETO_WINDOW > block.timestamp) {
            revert MinSlashingDelayNotPassed();
        }
        delete self.slashingRequests[slashRoot];
        uint256 len = queuedSlashing.vaults.length
        for (uint256 i = 0; i < len; i++) {
            IKarakBaseVault(queuedSlashing.vaults[i]).slashAssets(
                queuedSlashing.earmarkedStakes[i],
                self.assetSlashingHandlers[IKarakBaseVault(queuedSlashing.vaults[i]).asset()]
            );
        }
        IDSS dss = queuedSlashing.dss;

        HookLib.callHookIfInterfaceImplemented({
            dss: dss,
            data: abi.encodeWithSelector(dss.finishSlashingHook.selector, queuedSlashing.operator),
            interfaceId: dss.finishSlashingHook.selector,
            ignoreFailure: true,
            hookCallGasLimit: self.hookCallGasLimit,
            supportsInterfaceGasLimit: self.supportsInterfaceGasLimit,
            hookGasBuffer: self.hookGasBuffer
        });
    }