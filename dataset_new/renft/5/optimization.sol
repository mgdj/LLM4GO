function removeRentals(
        bytes32 orderHash,
        RentalAssetUpdate[] calldata rentalAssetUpdates
    ) external onlyByProxy permissioned {
        // The order must exist to be deleted.
        if (!orders[orderHash]) {
            revert Errors.StorageModule_OrderDoesNotExist(orderHash);
        } else {
            // Delete the order from storage.
            delete orders[orderHash];
        }

        // Process each rental asset.
        for (uint256 i = 0; i < rentalAssetUpdates.length; ++i) {
            RentalAssetUpdate memory asset = rentalAssetUpdates[i];

            // Reduce the amount of tokens for the particular rental ID.
            if (asset.amount > 0) {
                rentedAssets[asset.rentalId] -= asset.amount;
            }
        }
    }