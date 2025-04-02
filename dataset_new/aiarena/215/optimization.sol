function addAttributeDivisor(uint8[] calldata attributeDivisors) external {
        require(msg.sender == _ownerAddress);

        uint256 attributesLength = attributes.length;
        require(attributeDivisors.length == attributesLength);

        for (uint8 i = 0; i < attributesLength;) {
            if(attributeToDnaDivisor[attributes[i]] != attributeDivisors[i]){
                attributeToDnaDivisor[attributes[i]] = attributeDivisors[i];
            }
            unchecked{
                ++i;
            }
        }
    }   