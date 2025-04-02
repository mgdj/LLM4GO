function _isValidSafeOwner(address owner, address safe) internal view {
         // Make sure the fulfiller is the owner of the recipient rental safe.
         if (!ISafe(safe).isOwner(owner)) {
             revert Errors.CreatePolicy_InvalidSafeOwner(owner, safe);
         }

        // Make sure only protocol-deployed safes can rent.
        if (STORE.deployedSafes(safe) == 0) {
            revert Errors.CreatePolicy_InvalidRentalSafe(safe);
        }

     }