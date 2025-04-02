function getUserTokensAndClaimable(address user) public view returns (UserClaimData[] memory) {
        address[] memory tokens = getUserTokens(user);
        UserClaimData[] memory result = new UserClaimData[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 claimable = getClaimableFees(token, user);
            result[i] = UserClaimData(claimable, token);
        }
        return result;
    }