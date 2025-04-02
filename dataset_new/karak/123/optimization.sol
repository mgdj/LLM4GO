    function processInclusionProofKeccak(bytes memory proof, bytes32 leaf, uint256 index)
        internal
        pure
        returns (bytes32)
    {
        // 使用自定义错误替代 require
        if (proof.length % 32 != 0) {
            revert InvalidProofLength(proof.length);
        }

        bytes32 computedHash = leaf;
        uint256 length = proof.length;
        for (uint256 i = 32; i <= length; i += 32) {
            if (index % 2 == 0) {
                // if ith bit of index is 0, then computedHash is a left sibling
                assembly {
                    mstore(0x00, computedHash)
                    mstore(0x20, mload(add(proof, i)))
                    computedHash := keccak256(0x00, 0x40)
                    index := div(index, 2)
                }
            } else {
                // if ith bit of index is 1, then computedHash is a right sibling
                assembly {
                    mstore(0x00, mload(add(proof, i)))
                    mstore(0x20, computedHash)
                    computedHash := keccak256(0x00, 0x40)
                    index := div(index, 2)
                }
            }
        }
        return computedHash;
    }

error InvalidProofLength(uint256 length);