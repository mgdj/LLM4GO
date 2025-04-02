function setMaxPoolPriceDifference(uint16 _maxPoolPriceDifference) external onlyOwner {
        if (_maxPoolPriceDifference < MIN_PRICE_DIFFERENCE) {
            revert InvalidConfig();
        }
        maxPoolPriceDifference = _maxPoolPriceDifference;
        emit SetMaxPoolPriceDifference(_maxPoolPriceDifference);
    }