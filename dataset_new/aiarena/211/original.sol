function redeemMintPass(
        uint256[] calldata mintpassIdsToBurn,
        uint8[] calldata fighterTypes,
        uint8[] calldata iconsTypes,
        string[] calldata mintPassDnas,
        string[] calldata modelHashes,
        string[] calldata modelTypes
    ) 
        external 
    {
        require(
            mintpassIdsToBurn.length == mintPassDnas.length && 
            mintPassDnas.length == fighterTypes.length && 
            fighterTypes.length == modelHashes.length &&
            modelHashes.length == modelTypes.length
        );
        for (uint16 i = 0; i < mintpassIdsToBurn.length; i++) {
            require(msg.sender == _mintpassInstance.ownerOf(mintpassIdsToBurn[i]));
            _mintpassInstance.burn(mintpassIdsToBurn[i]);
            _createNewFighter(
                msg.sender, 
                uint256(keccak256(abi.encode(mintPassDnas[i]))), 
                modelHashes[i], 
                modelTypes[i],
                fighterTypes[i],
                iconsTypes[i],
                [uint256(100), uint256(100)]
            );
        }
    }