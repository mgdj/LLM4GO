function getAttributeProbabilities(uint256 generation, string calldata attribute) 
        public 
        view 
        returns (uint8[] memory) 
    {
        return attributeProbabilities[generation][attribute];
    }  