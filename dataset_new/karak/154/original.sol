function validateBalanceContainer(bytes32 beaconBlockRoot, BalanceContainer calldata proof) internal view {
        if (proof.proof.length != 32 * (BEACON_BLOCK_HEADER_HEIGHT + BEACON_STATE_HEIGHT)) {
            revert InvalidBalanceRootProof();
        }

        uint256 index = (BEACON_STATE_ROOT_IDX << (BEACON_STATE_HEIGHT)) | BALANCE_CONTAINER_IDX;

        if (
            !Merkle.verifyInclusionSha256({
                proof: proof.proof,
                root: beaconBlockRoot,
                leaf: proof.containerRoot,
                index: index
            })
        ) revert InvalidBalanceRootProof();
    }