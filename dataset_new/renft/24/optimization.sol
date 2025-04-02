function _removeHooks(
        Hook[] calldata hooks,
        Item[] calldata rentalItems,
        address rentalWallet
    ) internal {
        // Define hook target, item index, and item.
        address target;
        uint256 itemIndex;
        Item memory item;

        // Loop through each hook in the payload.
        uint256 length = hooks.length;
        for (uint256 i = 0; i < length; ++i) {
            // Get the hook address.
            target = hooks[i].target;

            // Check that the hook is reNFT-approved to execute on rental stop.
            if (!STORE.hookOnStop(target)) {
                revert Errors.Shared_DisabledHook(target);
            }

            // Get the rental item index for this hook.
            itemIndex = hooks[i].itemIndex;

            // Get the rental item for this hook.
            item = rentalItems[itemIndex];

            // Make sure the item is a rented item.
            if (!item.isRental()) {
                revert Errors.Shared_NonRentalHookItem(itemIndex);
            }

            // Call the hook with data about the rented item.
            try
                IHook(target).onStop(
                    rentalWallet,
                    item.token,
                    item.identifier,
                    item.amount,
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