function getAttributeProbabilities(uint256 generation, string memory attribute) 
        public 
        view 
        returns (uint8[] memory) 
    {
        return attributeProbabilities[generation][attribute];
    }  