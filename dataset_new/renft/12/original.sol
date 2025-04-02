function requestPermissions()
        external
        view
        override
        onlyKernel
        returns (Permissions[] memory requests)
    {
        requests = new Permissions[](8);
        requests[0] = Permissions(
            toKeycode("STORE"),
            STORE.toggleWhitelistExtension.selector
        );
        requests[1] = Permissions(
            toKeycode("STORE"),
            STORE.toggleWhitelistDelegate.selector
        );
        requests[2] = Permissions(toKeycode("STORE"), STORE.upgrade.selector);
        requests[3] = Permissions(toKeycode("STORE"), STORE.freeze.selector);

        requests[4] = Permissions(toKeycode("ESCRW"), ESCRW.skim.selector);
        requests[5] = Permissions(toKeycode("ESCRW"), ESCRW.setFee.selector);
        requests[6] = Permissions(toKeycode("ESCRW"), ESCRW.upgrade.selector);
        requests[7] = Permissions(toKeycode("ESCRW"), ESCRW.freeze.selector);
    }