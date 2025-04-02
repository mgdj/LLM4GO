    function allowToken(address _token) external onlyAuthorized {
        isTokenAllowed[_token] = true;
        
    }