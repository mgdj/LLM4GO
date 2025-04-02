function reRoll(uint8 tokenId, uint8 fighterType) public {
    // Check ownership
    if (msg.sender != ownerOf(tokenId)) {
        revert Unauthorized(msg.sender);
    }

    // Check if the number of rerolls exceeds the allowed limit
    if (numRerolls[tokenId] >= maxRerollsAllowed[fighterType]) {
        revert ExceedsMaxRerolls(tokenId, fighterType);
    }

    // Check if the user has enough NRN tokens for the reroll
    uint256 userBalance = _neuronInstance.balanceOf(msg.sender);
    uint256 x = rerollCost;
    if (userBalance < x) {
        revert InsufficientNRN(rerollCost, userBalance);
    }

    // Approve and transfer the NRN cost for the reroll
    _neuronInstance.approveSpender(msg.sender, rerollCost);
    bool success = _neuronInstance.transferFrom(msg.sender, treasuryAddress, x);

    if (success) {
        // Increment the reroll count for this token
        numRerolls[tokenId] += 1;

        // Generate a new DNA for the fighter using a keccak256 hash
        uint256 dna = uint256(keccak256(abi.encode(msg.sender, tokenId, numRerolls[tokenId])));

        // Create the fighter's base attributes
        (uint256 element, uint256 weight, uint256 newDna) = _createFighterBase(dna, fighterType);

        // Update the fighter's attributes
        fighters[tokenId].element = element;
        fighters[tokenId].weight = weight;
        fighters[tokenId].physicalAttributes = _aiArenaHelperInstance.createPhysicalAttributes(
            newDna,
            generation[fighterType],
            fighters[tokenId].iconsType,
            fighters[tokenId].dendroidBool
        );

        // Clear the token URI to force a refresh
        _tokenURIs[tokenId] = "";
    }
}

error Unauthorized(address caller);
error ExceedsMaxRerolls(uint8 tokenId, uint8 fighterType);
error InsufficientNRN(uint256 required, uint256 available);