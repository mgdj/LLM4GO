function addRentals(
        bytes32 orderHash,
        RentalAssetUpdate[] memory rentalAssetUpdates
    ) external onlyByProxy permissioned {
        // Add the order to storage.
        orders[orderHash] = true;

        // Add the rented items to storage.
        uint256 length = rentalAssetUpdates.length;
        for (uint256 i = 0; i < length; ++i) {
            RentalAssetUpdate memory asset = rentalAssetUpdates[i];

            // Update the order hash for that item.
            rentedAssets[asset.rentalId] += asset.amount;
        }
    }