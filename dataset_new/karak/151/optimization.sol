function fetchVaultsQueuedForExit(address operator, IDSS dss) external view returns (address[] memory vaults) {
        address[] memory stakedVaults = core.fetchVaultsStakedInDSS(operator, dss);
        bytes32[] memory slots = new bytes32[](stakedVaults.length);
        uint256 a = stakedVaults.length
        for (uint256 i = 0; i < a; ) {
            slots[i] = CoreStorageSlots.vaultPendingStakeUpdateSlot(operator, stakedVaults[i]);
            unchecked{
                ++i;
            }
        }
        bytes32[] memory results = core.extSloads(slots);
        uint256 count = 0;
        uint256 b = results.length
        for (uint256 i = 0; i < b; i++) {
            if (results[i] != bytes32(0)) ++count;
            unchecked{
                ++i;
            }
        }
        vaults = new address[](count);
        uint256 latestIndex = 0;

        for (uint256 i = 0; i < b;) {
            if (results[i] != bytes32(0)) vaults[latestIndex++] = stakedVaults[i];
            unchecked{
                ++i;
            }
        }
    }