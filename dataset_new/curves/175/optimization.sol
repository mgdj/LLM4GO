function batchClaiming(address[] calldata tokenList) external {
        uint256 totalClaimable = 0;
        uint256 x = tokenList.length;
        for (uint256 i = 0; i < x; ) {
            address token = tokenList[i];
            updateFeeCredit(token, msg.sender);
            uint256 claimable = getClaimableFees(token, msg.sender);
            if (claimable != 0) {
                if(tokensData[token].unclaimedFees[msg.sender]!=0){
                    tokensData[token].unclaimedFees[msg.sender] = 0;
                }
                totalClaimable += claimable;
                emit FeesClaimed(token, msg.sender, claimable);
            }
            unchecked{++i;}
        }
        if (totalClaimable == 0) revert NoFeesToClaim();
        payable(msg.sender).transfer(totalClaimable);
    }