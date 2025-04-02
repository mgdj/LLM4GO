function requestPermissions()
        external
        view
        override
        onlyKernel
        returns (Permissions[] memory requests)
    {
        requests = new Permissions[](4);
        requests[0] = Permissions(toKeycode("STORE"), STORE.removeRentals.selector);
        requests[1] = Permissions(toKeycode("STORE"), STORE.removeRentalsBatch.selector);
        requests[2] = Permissions(toKeycode("ESCRW"), ESCRW.settlePayment.selector);
        requests[3] = Permissions(toKeycode("ESCRW"), ESCRW.settlePaymentBatch.selector);
    }