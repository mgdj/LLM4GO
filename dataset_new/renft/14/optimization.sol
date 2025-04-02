function requestPermissions()
        external
        view
        override
        onlyKernel
        returns (Permissions[] memory requests)
    {
        requests = new Permissions[](2);
        Storage _store = STORE;
        requests[0] = Permissions(toKeycode("STORE"), _store.updateHookPath.selector);
        requests[1] = Permissions(toKeycode("STORE"), _store.updateHookStatus.selector);
    }