function _processBaseOrderOffer(
        Item[] memory rentalItems,
        SpentItem[] memory offers,
        uint256 startIndex
    ) internal pure {
        // Must be at least one offer item.
        if (offers.length == 0) {
            revert Errors.CreatePolicy_OfferCountZero();
        }

        // Define elements of the item which depend on the token type.
        ItemType itemType;

        // Process each offer item.
        for (uint256 i; i < offers.length; ++i) {
            // Get the offer item.
            SpentItem memory offer = offers[i];

            // Handle the ERC721 item.
            if (offer.isERC721()) {
                itemType = ItemType.ERC721;
            }
            // Handle the ERC1155 item.
            else if (offer.isERC1155()) {
                itemType = ItemType.ERC1155;
            }
            // ERC20s are not supported as offer items in a BASE order.
            else {
                revert Errors.CreatePolicy_SeaportItemTypeNotSupported(offer.itemType);
            }

            // An ERC721 or ERC1155 offer item is considered a rented asset which will be
            // returned to the lender upon expiration of the rental order.
            rentalItems[i + startIndex] = Item({
                itemType: itemType,
                settleTo: SettleTo.LENDER,
                token: offer.token,
                amount: offer.amount,
                identifier: offer.identifier
            });
        }
    }