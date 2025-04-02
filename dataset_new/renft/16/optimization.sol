function requestPermissions()
        external
        view
        override
        onlyKernel
        returns (Permissions[] memory requests)
    {
        Storage _store = STORE;
        PaymentEscrow _escrw = ESCRW;
        requests = new Permissions[](4);
        requests[0] = Permissions(toKeycode("STORE"), _store.removeRentals.selector);
        requests[1] = Permissions(toKeycode("STORE"), _store.removeRentalsBatch.selector);
        requests[2] = Permissions(toKeycode("ESCRW"), _escrw.settlePayment.selector);
        requests[3] = Permissions(toKeycode("ESCRW"), _escrw.settlePaymentBatch.selector);
    }