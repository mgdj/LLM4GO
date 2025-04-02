function getUserTokensAndClaimable(address user) public view returns (UserClaimData[] memory) {
        address[] memory tokens = getUserTokens(user);
        UserClaimData[] memory result = new UserClaimData[](tokens.length);
        uint256 x = tokens.length;
        for (uint256 i = 0; i < x; ) {
            address token = tokens[i];
            uint256 claimable = getClaimableFees(token, user);
            result[i] = UserClaimData(claimable, token);
            unchecked{++i;}
        }
        return result;
    }