library CoreLib {
    using Operator for Operator.State;

    /// @custom:storage-location erc7201:core.storage
    struct Storage {
        // Operator
        mapping(address operator => Operator.State) operatorState;
        // Vault
        mapping(address vault => address implementation) vaultToImplMap;
        mapping(address implementation => bool) allowlistedVaultImpl;
        // Assets
        mapping(address asset => address slashingHandler) assetSlashingHandlers;
        // DSS
        mapping(bytes32 slashRoot => bool) slashingRequests;
        mapping(IDSS dss => uint256 slashablePercentageWad) dssMaxSlashablePercentageWad;
        address vaultImpl;
        uint96 vaultNonce;
        address vetoCommittee;
        uint96 nonce;
        uint32 hookCallGasLimit;
        uint32 supportsInterfaceGasLimit;
        uint32 hookGasBuffer;
    }