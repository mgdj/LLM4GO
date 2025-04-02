function settlePayment(RentalOrder calldata order) external onlyByProxy payable permissioned {
        // Settle all payments for the order.
        _settlePayment(
            order.items,
            order.orderType,
            order.lender,
            order.renter,
            order.startTimestamp,
            order.endTimestamp
        );
    }
