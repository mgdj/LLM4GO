function addSlashableToken(IERC20 token) external onlyOwner {
        _config().supportedAssets[token] = true;
    }