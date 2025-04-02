function validateBeaconStateRootProof(bytes32 beaconBlockRoot, BeaconStateRootProof calldata beaconStateRootProof)
        internal
        view
    {
        if (beaconStateRootProof.proof.length != 32 * (BEACON_BLOCK_HEADER_HEIGHT)) revert InvalidBeaconStateProof();
        if (
            !Merkle.verifyInclusionSha256(
                beaconStateRootProof.proof, beaconBlockRoot, beaconStateRootProof.beaconStateRoot, BEACON_STATE_ROOT_IDX
            )
        ) revert InvalidBeaconStateProof();
    }