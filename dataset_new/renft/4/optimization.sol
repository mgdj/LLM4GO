function addRentals(
        bytes32 orderHash,
        RentalAssetUpdate[] memory rentalAssetUpdates
    ) external onlyByProxy permissioned {
        // Add the order to storage.
        if(orders[orderHash] == false){
            orders[orderHash] = true;
        }

        // Add the rented items to storage.
        for (uint256 i = 0; i < rentalAssetUpdates.length; ++i) {
            RentalAssetUpdate memory asset = rentalAssetUpdates[i];

            // Update the order hash for that item.
            if (asset.amount > 0) {
                rentedAssets[asset.rentalId] += asset.amount;
            }
        }
    }