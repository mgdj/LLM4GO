function validateBalance(bytes32 balanceRoot, uint40 validatorIndex, BalanceProof calldata proof)
        internal
        view
        returns (uint256 validatorBalanceWei)
    {
        if (proof.proof.length != 32 * (BALANCE_HEIGHT + 1)) revert InvalidBalanceProof();

        uint256 balanceIndex = uint256(validatorIndex >> 2);

        if (
            !Merkle.verifyInclusionSha256({
                proof: proof.proof,
                root: balanceRoot,
                leaf: proof.balanceRoot,
                index: balanceIndex
            })
        ) revert InvalidBalanceProof();

        /// Extract the individual validator's balance from the `balanceRoot`
        uint256 bitShiftAmount = (validatorIndex % 4) << 6;
        return uint256(fromLittleEndianUint64(bytes32((uint256(proof.balanceRoot) << bitShiftAmount)))) * 1 gwei;
    }