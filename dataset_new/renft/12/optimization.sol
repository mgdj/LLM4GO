function requestPermissions()
        external
        view
        override
        onlyKernel
        returns (Permissions[] memory requests)
    {
        Storage _store = STORE;
        PaymentEscrow _escrw = ESCRW;
        requests = new Permissions[](8);
        requests[0] = Permissions(
            toKeycode("STORE"),
            _store.toggleWhitelistExtension.selector
        );
        requests[1] = Permissions(
            toKeycode("STORE"),
            _store.toggleWhitelistDelegate.selector
        );
        requests[2] = Permissions(toKeycode("STORE"), _store.upgrade.selector);
        requests[3] = Permissions(toKeycode("STORE"), _store.freeze.selector);

        requests[4] = Permissions(toKeycode("ESCRW"), _escrw.skim.selector);
        requests[5] = Permissions(toKeycode("ESCRW"), _escrw.setFee.selector);
        requests[6] = Permissions(toKeycode("ESCRW"), _escrw.upgrade.selector);
        requests[7] = Permissions(toKeycode("ESCRW"), _escrw.freeze.selector);
    }