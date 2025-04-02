function processInclusionProofSha256(bytes memory proof, bytes32 leaf, uint256 index)
        internal
        view
        returns (bytes32)
    {
        require(
            proof.length != 0 && proof.length % 32 == 0,
            "Merkle.processInclusionProofSha256: proof length should be a non-zero multiple of 32"
        );
        bytes32[1] memory computedHash = [leaf];
        uint256 len = proof.length
        for (uint256 i = 32; i <= len; i += 32) {
            if (index % 2 == 0) {
                // if ith bit of index is 0, then computedHash is a left sibling
                assembly {
                    mstore(0x00, mload(computedHash))
                    mstore(0x20, mload(add(proof, i)))
                    if iszero(staticcall(sub(gas(), 2000), 2, 0x00, 0x40, computedHash, 0x20)) { revert(0, 0) }
                    index := div(index, 2)
                }
            } else {
                // if ith bit of index is 1, then computedHash is a right sibling
                assembly {
                    mstore(0x00, mload(add(proof, i)))
                    mstore(0x20, mload(computedHash))
                    if iszero(staticcall(sub(gas(), 2000), 2, 0x00, 0x40, computedHash, 0x20)) { revert(0, 0) }
                    index := div(index, 2)
                }
            }
        }
        return computedHash[0];
    }