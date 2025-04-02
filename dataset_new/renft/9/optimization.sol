function _rentFromZone(
        RentPayload memory payload,
        SeaportPayload memory seaportPayload
    ) internal {
        // Check: make sure order metadata is valid with the given seaport order zone hash.
        _isValidOrderMetadata(payload.metadata, seaportPayload.zoneHash);

        // Check: verify the fulfiller of the order is an owner of the recipient safe.
        _isValidSafeOwner(seaportPayload.fulfiller, payload.fulfillment.recipient);

        // Check: verify each execution was sent to the expected destination.
        _executionInvariantChecks(
            seaportPayload.totalExecutions,
            payload.fulfillment.recipient
        );

        // Check: validate and process seaport offer and consideration items based
        // on the order type.
        Item[] memory items = _convertToItems(
            seaportPayload.offer,
            seaportPayload.consideration,
            payload.metadata.orderType
        );
        PaymentEscrow _escrw = ESCRW;
        // PAYEE orders are considered mirror-images of a PAY order. So, PAYEE orders
        // do not need to be processed in the same way that other order types do.
        if (
            payload.metadata.orderType.isBaseOrder() ||
            payload.metadata.orderType.isPayOrder()
        ) {
            // Create an accumulator which will hold all of the rental asset updates, consisting of IDs and
            // the rented amount. From this point on, new memory cannot be safely allocated until the
            // accumulator no longer needs to include elements.
            bytes memory rentalAssetUpdates = new bytes(0);

            // Check if each item is a rental. If so, then generate the rental asset update.
            // Memory will become safe again after this block.
            for (uint256 i; i < items.length; ++i) {
                if (items[i].isRental()) {
                    // Insert the rental asset update into the dynamic array.
                    _insert(
                        rentalAssetUpdates,
                        items[i].toRentalId(payload.fulfillment.recipient),
                        items[i].amount
                    );
                }
            }

            // Generate the rental order.
            RentalOrder memory order = RentalOrder({
                seaportOrderHash: seaportPayload.orderHash,
                items: items,
                hooks: payload.metadata.hooks,
                orderType: payload.metadata.orderType,
                lender: seaportPayload.offerer,
                renter: payload.intendedFulfiller,
                rentalWallet: payload.fulfillment.recipient,
                startTimestamp: block.timestamp,
                endTimestamp: block.timestamp + payload.metadata.rentDuration
            });

            // Compute the order hash.
            bytes32 orderHash = _deriveRentalOrderHash(order);

            // Interaction: Update storage only if the order is a Base Order or Pay order.
            STORE.addRentals(orderHash, _convertToStatic(rentalAssetUpdates));

            // Interaction: Increase the deposit value on the payment escrow so
            // it knows how many tokens were sent to it.
            for (uint256 i = 0; i < items.length; ++i) {
                if (items[i].isERC20()) {
                    _escrw.increaseDeposit(items[i].token, items[i].amount);
                }
            }

            // Interaction: Process the hooks associated with this rental.
            if (payload.metadata.hooks.length > 0) {
                _addHooks(
                    payload.metadata.hooks,
                    seaportPayload.offer,
                    payload.fulfillment.recipient
                );
            }

            // Emit rental order started.
            _emitRentalOrderStarted(order, orderHash, payload.metadata.emittedExtraData);
        }
    }