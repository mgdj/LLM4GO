function storeRatesAtExpiry() public override afterExpiry {
        if (ratesAtExpiryStored) {
            revert RatesAtExpiryAlreadyStored();
        }
        ratesAtExpiryStored = true;
        // PT rate not rounded up here
        uint256 _ptRate;
        uint256 _ibtRate;

        (_ptRate, _ibtRate) = _getCurrentPTandIBTRates(false);
        ptRate = _ptRate;
        ibtRate = _ibtRate;
        emit RatesStoredAtExpiry(_ibtRate, _ptRate);
    }