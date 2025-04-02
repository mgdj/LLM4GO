function upgradeAndCall(
        IAMTransparentUpgradeableProxy proxy,
        address implementation,
        bytes memory data
    ) public payable virtual restricted {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }