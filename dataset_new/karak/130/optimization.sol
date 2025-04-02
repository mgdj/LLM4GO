function addSlashableToken(IERC20 token) external payable onlyOwner {
        _config().supportedAssets[token] = true;
    }