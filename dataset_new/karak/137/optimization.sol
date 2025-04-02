function createVault(
        Storage storage self,
        address operator,
        address depositToken,
        string memory name,
        string memory symbol,
        bytes memory extraData,
        address implementation
    ) internal returns (IKarakBaseVault) {
        // Use Create2 to determine the address before hand
        bytes32 salt = keccak256(abi.encodePacked(operator, depositToken, ++self.vaultNonce));

        address expectedNewVaultAddr =
            LibClone.predictDeterministicAddressERC1967BeaconProxy(address(this), salt, address(this));

        self.vaultToImplMap[address(expectedNewVaultAddr)] = implementation;

        IKarakBaseVault vault = cloneVault(salt);
        vault.initialize(address(this), operator, depositToken, name, symbol, extraData);

        // Extra protection to ensure the vault was created with the correct address
        if (expectedNewVaultAddr != address(vault)) {
            revert VaultCreationFailedAddrMismatch(expectedNewVaultAddr, address(vault));
        }

        emit NewVault(address(vault), implementation);
        return vault;
    }