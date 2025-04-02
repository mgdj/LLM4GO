function addAttributeProbabilities(uint256 generation, uint8[][] calldata probabilities) public {
        if (msg.sender != _ownerAddress) {
            revert Unauthorized(msg.sender); // Custom error instead of string message
        }

        if (probabilities.length != 6) {
            revert InvalidAttributeCount(probabilities.length); // Custom error with count value
        }

        uint256 attributesLength = attributes.length;
        for (uint8 i = 0; i < attributesLength;) {
            if(attributeProbabilities[generation][attributes[i]] != probabilities[i]){
                attributeProbabilities[generation][attributes[i]] = probabilities[i];
            }
            unchecked{
                ++i;
            }
        }
    }
    error Unauthorized(address caller);
    error InvalidAttributeCount(uint256 count);