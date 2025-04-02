function _processPayOrderOffer(
        Item[] memory rentalItems,
        SpentItem[] memory offers,
        uint256 startIndex
    ) internal pure {
        // Keep track of each item type.
        uint256 totalRentals;
        uint256 totalPayments;

        // Define elements of the item which depend on the token type.
        ItemType itemType;
        SettleTo settleTo;

        // Process each offer item.
        for (uint256 i; i < offers.length; ++i) {
            // Get the offer item.
            SpentItem memory offer = offers[i];

            // Handle the ERC721 item.
            if (offer.isERC721()) {
                // The ERC721 will be returned to the lender upon expiration
                // of the rental order.
                itemType = ItemType.ERC721;
                settleTo = SettleTo.LENDER;

                // Increment rentals.
                ++totalRentals;
            }
            // Handle the ERC1155 item.
            else if (offer.isERC1155()) {
                // The ERC1155 will be returned to the lender upon expiration
                // of the rental order.
                itemType = ItemType.ERC1155;
                settleTo = SettleTo.LENDER;

                // Increment rentals.
                ++totalRentals;
            }
            // Process an ERC20 offer item.
            else if (offer.isERC20()) {
                // An ERC20 offer item is considered a payment to the renter upon
                // expiration of the rental order.
                itemType = ItemType.ERC20;
                settleTo = SettleTo.RENTER;

                // Increment payments.
                ++totalPayments;
            }
            // Revert if unsupported item type.
            else {
                revert Errors.CreatePolicy_SeaportItemTypeNotSupported(offer.itemType);
            }

            // Create the item.
            rentalItems[i + startIndex] = Item({
                itemType: itemType,
                settleTo: settleTo,
                token: offer.token,
                amount: offer.amount,
                identifier: offer.identifier
            });
        }

        // PAY order offer must have at least one rental and one payment.
        if (totalRentals == 0 || totalPayments == 0) {
            revert Errors.CreatePolicy_ItemCountZero(totalRentals, totalPayments);
        }
    }