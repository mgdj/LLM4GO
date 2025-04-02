    function setLoopAddresses(address _loopAddress, address _vaultAddress)
        external
        onlyAuthorized
        onlyBeforeDate(loopActivation)
    {
        if(lpETH!=ILpETH(_loopAddress) || lpETHVault!=ILpETHVault(_vaultAddress)){
            lpETH = ILpETH(_loopAddress);
            lpETHVault = ILpETHVault(_vaultAddress);
        }
        
        loopActivation = uint32(block.timestamp);

        emit LoopAddressesUpdated(_loopAddress, _vaultAddress);
    }