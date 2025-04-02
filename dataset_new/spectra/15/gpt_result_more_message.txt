function upgradeAndCall(
        IAMTransparentUpgradeableProxy proxy,
        address implementation,
        bytes calldata data
    ) public payable virtual restricted {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }