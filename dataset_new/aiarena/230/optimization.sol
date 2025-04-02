function claimNRN() external {
        require(numRoundsClaimed[msg.sender] < roundId);
        uint256 claimableNRN = 0;
        uint256 nrnDistribution;
        uint32 lowerBound = numRoundsClaimed[msg.sender];
        for (uint32 currentRound = lowerBound; currentRound < roundId; ) {
            nrnDistribution = getNrnDistribution(currentRound);
            claimableNRN += (
                accumulatedPointsPerAddress[msg.sender][currentRound] * nrnDistribution   
            ) / totalAccumulatedPoints[currentRound];
            numRoundsClaimed[msg.sender] += 1;
            unchecked{
                ++currentRound;
            }
        }
        if (claimableNRN != 0) {
            amountClaimed[msg.sender] = amountClaimed[msg.sender] + claimableNRN;
            _neuronInstance.mint(msg.sender, claimableNRN);
            emit Claimed(msg.sender, claimableNRN);
        }
    }