function requestPermissions()
        external
        view
        override
        onlyKernel
        returns (Permissions[] memory requests)
    {
        requests = new Permissions[](2);
        requests[0] = Permissions(toKeycode("STORE"), STORE.updateHookPath.selector);
        requests[1] = Permissions(toKeycode("STORE"), STORE.updateHookStatus.selector);
    }