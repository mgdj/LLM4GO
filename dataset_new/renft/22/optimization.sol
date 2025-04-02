function _deriveRentalOrderHash(
        RentalOrder memory order
    ) internal view returns (bytes32) {
        // Create arrays for items and hooks.
        bytes32[] memory itemHashes = new bytes32[](order.items.length);
        bytes32[] memory hookHashes = new bytes32[](order.hooks.length);

        // Iterate over each item.
        uint256 length = order.items.length;
        for (uint256 i = 0; i < length; ++i) {
            // Hash the item.
            itemHashes[i] = _deriveItemHash(order.items[i]);
        }

        // Iterate over each hook.
        uint256 hookslength = order.hooks.length;
        for (uint256 i = 0; i < hookslength; ++i) {
            // Hash the hook.
            hookHashes[i] = _deriveHookHash(order.hooks[i]);
        }

        return
            keccak256(
                abi.encode(
                    _RENTAL_ORDER_TYPEHASH,
                    order.seaportOrderHash,
                    keccak256(abi.encodePacked(itemHashes)),
                    keccak256(abi.encodePacked(hookHashes)),
                    order.orderType,
                    order.lender,
                    order.renter,
                    order.startTimestamp,
                    order.endTimestamp
                )
            );
    }