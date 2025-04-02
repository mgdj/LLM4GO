function _settlePayment(
        Item[] calldata items,
        OrderType orderType,
        address lender,
        address renter,
        uint256 start,
        uint256 end
    ) internal {
        // Calculate the time values.
        uint256 elapsedTime = block.timestamp - start;
        uint256 totalTime = end - start;

        // Determine whether the rental order has ended.
        bool isRentalOver = elapsedTime >= totalTime;

        // Loop through each item in the order.
        for (uint256 i = 0; i < items.length; ++i) {
            // Get the item.
            Item memory item = items[i];

            // Check that the item is a payment.
            if (item.isERC20()) {
                // Set a placeholder payment amount which can be reduced in the
                // presence of a fee.
                uint256 paymentAmount = item.amount;

                // Take a fee on the payment amount if the fee is on.
                if (fee != 0) {
                    // Calculate the new fee.
                    uint256 paymentFee = _calculateFee(paymentAmount);

                    // Adjust the payment amount by the fee.
                    paymentAmount -= paymentFee;
                }

                // Effect: Decrease the token balance. Use the payment amount pre-fee
                // so that fees can be taken.
                _decreaseDeposit(item.token, item.amount);

                // If its a PAY order but the rental hasn't ended yet.
                if (orderType.isPayOrder() && !isRentalOver) {
                    // Interaction: a PAY order which hasnt ended yet. Payout is pro-rata.
                    _settlePaymentProRata(
                        item.token,
                        paymentAmount,
                        lender,
                        renter,
                        elapsedTime,
                        totalTime
                    );
                }
                // If its a PAY order and the rental is over, or, if its a BASE order.
                else if (
                    (orderType.isPayOrder() && isRentalOver) || orderType.isBaseOrder()
                ) {
                    // Interaction: a pay order or base order which has ended. Payout is in full.
                    _settlePaymentInFull(
                        item.token,
                        paymentAmount,
                        item.settleTo,
                        lender,
                        renter
                    );
                } else {
                    revert Errors.Shared_OrderTypeNotSupported(uint8(orderType));
                }
            }
        }
    }