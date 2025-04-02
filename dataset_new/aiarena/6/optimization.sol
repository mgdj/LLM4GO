function claimRewards(
        string[] calldata modelURIs, 
        string[] calldata modelTypes,
        uint256[2][] calldata customAttributes
    ) 
        external 
    {
        uint256 winnersLength;
        uint32 claimIndex = 0;
        uint32 lowerBound = numRoundsClaimed[msg.sender];
        uint32 tempround = 0;
        for (uint32 currentRound = lowerBound; currentRound < roundId; currentRound++) {
            tempround += 1;
            winnersLength = winnerAddresses[currentRound].length;
            for (uint32 j = 0; j < winnersLength; j++) {
                if (msg.sender == winnerAddresses[currentRound][j]) {
                    _fighterFarmInstance.mintFromMergingPool(
                        msg.sender,
                        modelURIs[claimIndex],
                        modelTypes[claimIndex],
                        customAttributes[claimIndex]
                    );
                    claimIndex += 1;
                }
            }
        }
        numRoundsClaimed[msg.sender] += tempround;
        if (claimIndex > 0) {
            emit Claimed(msg.sender, claimIndex);
        }
    }