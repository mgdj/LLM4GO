function _addResultPoints(
        uint8 battleResult, 
        uint256 tokenId, 
        uint256 eloFactor, 
        uint256 mergingPortion,
        address fighterOwner
    ) 
        private 
    {
        uint256 stakeAtRisk;
        uint256 curStakeAtRisk;
        uint256 points = 0;

        /// Check how many NRNs the fighter has at risk
        stakeAtRisk = _stakeAtRiskInstance.getStakeAtRisk(tokenId);

        /// Calculate the staking factor if it has not already been calculated for this round 
        if (_calculatedStakingFactor[tokenId][roundId] == false) {
            stakingFactor[tokenId] = _getStakingFactor(tokenId, stakeAtRisk);
            _calculatedStakingFactor[tokenId][roundId] = true;
        }

        /// Potential amount of NRNs to put at risk or retrieve from the stake-at-risk contract
        curStakeAtRisk = (bpsLostPerLoss * (amountStaked[tokenId] + stakeAtRisk)) / 10**4;
        if (battleResult == 0) {
            /// If the user won the match

            /// If the user has no NRNs at risk, then they can earn points
            if (stakeAtRisk == 0) {
                points = stakingFactor[tokenId] * eloFactor;
            }

            /// Divert a portion of the points to the merging pool
            uint256 mergingPoints = (points * mergingPortion) / 100;
            points -= mergingPoints;
            _mergingPoolInstance.addPoints(tokenId, mergingPoints);

            /// Do not allow users to reclaim more NRNs than they have at risk
            if (curStakeAtRisk > stakeAtRisk) {
                curStakeAtRisk = stakeAtRisk;
            }

            /// If the user has stake-at-risk for their fighter, reclaim a portion
            /// Reclaiming stake-at-risk puts the NRN back into their staking pool
            if (curStakeAtRisk > 0) {
                _stakeAtRiskInstance.reclaimNRN(curStakeAtRisk, tokenId, fighterOwner);
                amountStaked[tokenId] += curStakeAtRisk;
            }

            /// Add points to the fighter for this round
            accumulatedPointsPerFighter[tokenId][roundId] += points;
            accumulatedPointsPerAddress[fighterOwner][roundId] += points;
            totalAccumulatedPoints[roundId] += points;
            if (points > 0) {
                emit PointsChanged(tokenId, points, true);
            }
        } else if (battleResult == 2) {
            /// If the user lost the match

            /// Do not allow users to lose more NRNs than they have in their staking pool
            if (curStakeAtRisk > amountStaked[tokenId]) {
                curStakeAtRisk = amountStaked[tokenId];
            }
            if (accumulatedPointsPerFighter[tokenId][roundId] > 0) {
                /// If the fighter has a positive point balance for this round, deduct points 
                points = stakingFactor[tokenId] * eloFactor;
                if (points > accumulatedPointsPerFighter[tokenId][roundId]) {
                    points = accumulatedPointsPerFighter[tokenId][roundId];
                }
                accumulatedPointsPerFighter[tokenId][roundId] -= points;
                accumulatedPointsPerAddress[fighterOwner][roundId] -= points;
                totalAccumulatedPoints[roundId] -= points;
                if (points > 0) {
                    emit PointsChanged(tokenId, points, false);
                }
            } else {
                /// If the fighter does not have any points for this round, NRNs become at risk of being lost
                bool success = _neuronInstance.transfer(_stakeAtRiskAddress, curStakeAtRisk);
                if (success) {
                    _stakeAtRiskInstance.updateAtRiskRecords(curStakeAtRisk, tokenId, fighterOwner);
                    amountStaked[tokenId] -= curStakeAtRisk;
                }
            }
        }
    }