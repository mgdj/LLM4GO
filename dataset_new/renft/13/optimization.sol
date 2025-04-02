function deployRentalSafe(
        address[] calldata owners,
        uint256 threshold
    ) external returns (address safe) {
        // Require that the threshold is valid.
        if (threshold == 0 || threshold > owners.length) {
            revert Errors.FactoryPolicy_InvalidSafeThreshold(threshold, owners.length);
        }

        // Delegate call from the safe so that the rental manager module can be enabled
        // right after the safe is deployed.
        bytes memory data = abi.encodeCall(
            Factory.initializeRentalSafe,
            (address(stopPolicy), address(guardPolicy))
        );
        Storage _store = STORE;
        // Create gnosis initializer payload.
        bytes memory initializerPayload = abi.encodeCall(
            ISafe.setup,
            (
                // owners array.
                owners,
                // number of signatures needed to execute transactions.
                threshold,
                // Address to direct the payload to.
                address(this),
                // Encoded call to execute.
                data,
                // Fallback manager address.
                address(fallbackHandler),
                // Payment token.
                address(0),
                // Payment amount.
                0,
                // Payment receiver
                payable(address(0))
            )
        );

        // Deploy a safe proxy using initializer values for the Safe.setup() call
        // with a salt nonce that is unique to each chain to guarantee cross-chain
        // unique safe addresses.
        safe = address(
            safeProxyFactory.createProxyWithNonce(
                address(safeSingleton),
                initializerPayload,
                uint256(keccak256(abi.encode(_store.totalSafes() + 1, block.chainid)))
            )
        );

        // Store the deployed safe.
        _store.addRentalSafe(safe);

        // Emit the event.
        emit Events.RentalSafeDeployment(safe, owners, threshold);
    }