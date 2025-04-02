function validateValidatorProof(
        uint40 validatorIndex,
        bytes32[] calldata validatorFields,
        bytes calldata validatorProof,
        bytes32 beaconStateRoot
    ) internal view {
        if (validatorFields.length != NUM_FIELDS) revert InvalidValidatorFieldsLength();

        bytes32 validatorRoot = Merkle.merkleizeSha256(validatorFields);

        // Calculate the index for validator proof verification
        // Shift the container index left by the sum of validator height and one, then combine with the validator index
        uint256 index = (CONTAINER_IDX << (VALIDATOR_HEIGHT + 1)) | uint256(validatorIndex);

        // Validate the length of the validator proof
        if (validatorProof.length != 32 * ((VALIDATOR_HEIGHT + 1) + BEACON_STATE_HEIGHT)) {
            revert InvalidValidatorFieldsProofLength();
        }
        // Validate the inclusion of the validator root in the beacon state root
        if (!Merkle.verifyInclusionSha256(validatorProof, beaconStateRoot, validatorRoot, index)) {
            revert InvalidValidatorFieldsProofInclusion();
        }
    }