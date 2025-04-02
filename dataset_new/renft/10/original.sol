function _executionInvariantChecks(
        ReceivedItem[] memory executions,
        address expectedRentalSafe
    ) internal view {
        for (uint256 i = 0; i < executions.length; ++i) {
            ReceivedItem memory execution = executions[i];

            // ERC20 invariant where the recipient must be the payment escrow.
            if (execution.isERC20()) {
                _checkExpectedRecipient(execution, address(ESCRW));
            }
            // ERC721 and ERC1155 invariants where the recipient must
            // be the expected rental safe.
            else if (execution.isRental()) {
                _checkExpectedRecipient(execution, expectedRentalSafe);
            }
            // Revert if unsupported item type.
            else {
                revert Errors.CreatePolicy_SeaportItemTypeNotSupported(
                    execution.itemType
                );
            }
        }
    }