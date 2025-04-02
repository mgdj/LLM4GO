function addAttributeDivisor(uint8[] memory attributeDivisors) external {
        require(msg.sender == _ownerAddress);
        require(attributeDivisors.length == attributes.length);

        uint256 attributesLength = attributes.length;
        for (uint8 i = 0; i < attributesLength; i++) {
            attributeToDnaDivisor[attributes[i]] = attributeDivisors[i];
        }
    }  