    function init(
        Storage storage self,
        address _vaultImpl,
        address _vetoCommittee,
        uint32 _hookCallGasLimit,
        uint32 _supportsInterfaceGasLimit,
        uint32 _hookGasBuffer
    ) internal {
        if (_vaultImpl == address(0) || _vetoCommittee == address(0)) {
            revert ZeroAddress();
        }
        self.vaultImpl = _vaultImpl;
        self.vetoCommittee = _vetoCommittee;
        updateGasValues(self, _hookCallGasLimit, _supportsInterfaceGasLimit, _hookGasBuffer);
    }