function init(
    Storage storage self,
    address _vaultImpl,
    address _vetoCommittee,
    uint32 _hookCallGasLimit,
    uint32 _supportsInterfaceGasLimit,
    uint32 _hookGasBuffer
) internal {
    // Assembly block to check for _vaultImpl == address(0) or _vetoCommittee == address(0)
    assembly {
        if or(iszero(_vaultImpl), iszero(_vetoCommittee)) {
            mstore(0x00, 0x4e487b71) // Custom error selector for ZeroAddress()
            revert(0x00, 0x04)
        }
    }

    self.vaultImpl = _vaultImpl;
    self.vetoCommittee = _vetoCommittee;
    updateGasValues(self, _hookCallGasLimit, _supportsInterfaceGasLimit, _hookGasBuffer);
}