function multicall(bytes[] calldata data) public payable returns (bytes[] memory results) {
    results = new bytes[](data.length);
    for (uint256 i = 0; i < data.length; ) {
        (bool success, bytes memory result) = address(this).delegatecall(data[i]);

        if (!success) {
            // Bubble up the revert reason
            // The bytes type is ABI encoded as a length-prefixed byte array
            // So we simply need to add 32 to the pointer to get the start of the data
            // And then revert with the size loaded from the first 32 bytes
            // Other solutions will do work to differentiate the revert reasons and provide paranthetical information
            // However, we have chosen to simply replicate the the normal behavior of the call
            // NOTE: memory-safe because it reads from memory already allocated by solidity (the bytes memory result)
            assembly ("memory-safe") {
                revert(add(result, 32), mload(result))
            }
        }

        results[i] = result;

        unchecked {
            ++i;
        }
    }
}