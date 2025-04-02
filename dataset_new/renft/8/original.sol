function _addHooks(
        Hook[] memory hooks,
        SpentItem[] memory offerItems,
        address rentalWallet
    ) internal {
        // Define hook target, offer item index, and an offer item.
        address target;
        uint256 itemIndex;
        SpentItem memory offer;

        // Loop through each hook in the payload.
        for (uint256 i = 0; i < hooks.length; ++i) {
            // Get the hook's target address.
            target = hooks[i].target;

            // Check that the hook is reNFT-approved to execute on rental start.
            if (!STORE.hookOnStart(target)) {
                revert Errors.Shared_DisabledHook(target);
            }

            // Get the offer item index for this hook.
            itemIndex = hooks[i].itemIndex;

            // Get the offer item for this hook.
            offer = offerItems[itemIndex];

            // Make sure the offer item is an ERC721 or ERC1155.
            if (!offer.isRental()) {
                revert Errors.Shared_NonRentalHookItem(itemIndex);
            }

            // Call the hook with data about the rented item.
            try
                IHook(target).onStart(
                    rentalWallet,
                    offer.token,
                    offer.identifier,
                    offer.amount,
                    hooks[i].extraData
                )
            {} catch Error(string memory revertReason) {
                // Revert with reason given.
                revert Errors.Shared_HookFailString(revertReason);
            } catch Panic(uint256 errorCode) {
                // Convert solidity panic code to string.
                string memory stringErrorCode = LibString.toString(errorCode);

                // Revert with panic code.
                revert Errors.Shared_HookFailString(
                    string.concat("Hook reverted: Panic code ", stringErrorCode)
                );
            } catch (bytes memory revertData) {
                // Fallback to an error that returns the byte data.
                revert Errors.Shared_HookFailBytes(revertData);
            }
        }
    }