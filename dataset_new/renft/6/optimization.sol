function removeRentalsBatch(
        bytes32[] calldata orderHashes,
        RentalAssetUpdate[] calldata rentalAssetUpdates
    ) external onlyByProxy permissioned {
        // Delete the orders from storage.
        for (uint256 i = 0; i < orderHashes.length; ++i) {
            // The order must exist to be deleted.
            if (!orders[orderHashes[i]]) {
                revert Errors.StorageModule_OrderDoesNotExist(orderHashes[i]);
            } else {
                // Delete the order from storage.
                delete orders[orderHashes[i]];
            }
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