function storeRatesAtExpiry() public override afterExpiry {
        if (ratesAtExpiryStored) {
            revert RatesAtExpiryAlreadyStored();
        }
        ratesAtExpiryStored = true;
        // PT rate not rounded up here
        (ptRate, ibtRate) = _getCurrentPTandIBTRates(false);
        emit RatesStoredAtExpiry(ibtRate, ptRate);
    }