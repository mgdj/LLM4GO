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
        uint16 x = mintpassIdsToBurn.length;
        require(x == mintPassDnas.length);
        require(mintPassDnas.length == fighterTypes.length);
        require(fighterTypes.length == modelHashes.length);
        require(modelHashes.length == modelTypes.length);
        AAMintPass tmp = _mintpassInstance;
        for (uint16 i = 0; i < x; ) {
            require(msg.sender == tmp.ownerOf(mintpassIdsToBurn[i]));
            tmp.burn(mintpassIdsToBurn[i]);
            _createNewFighter(
                msg.sender, 
                uint256(keccak256(abi.encode(mintPassDnas[i]))), 
                modelHashes[i], 
                modelTypes[i],
                fighterTypes[i],
                iconsTypes[i],
                [uint256(100), uint256(100)]
            );
            unchecked{
                ++i;
            }
        }
    }