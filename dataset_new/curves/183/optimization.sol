function _deployERC20(
        address curvesTokenSubject,
        string calldata name,
        string calldata symbol
    ) internal returns (address) {
        // If the token's symbol is CURVES, append a counter value
        if (symbolToSubject[symbol] != address(0)) revert InvalidERC20Metadata();
        if (keccak256(bytes(symbol)) == keccak256(bytes(DEFAULT_SYMBOL))) {
            uint256 counter = _curvesTokenCounter + 1;
            name = string(abi.encodePacked(name, " ", Strings.toString(counter)));
            symbol = string(abi.encodePacked(symbol, Strings.toString(counter)));
            _curvesTokenCounter = counter;
        }


        address tokenContract = CurvesERC20Factory(curvesERC20Factory).deploy(name, symbol, address(this));

        externalCurvesTokens[curvesTokenSubject].token = tokenContract;
        externalCurvesTokens[curvesTokenSubject].name = name;
        externalCurvesTokens[curvesTokenSubject].symbol = symbol;
        externalCurvesToSubject[tokenContract] = curvesTokenSubject;
        symbolToSubject[symbol] = curvesTokenSubject;

        emit TokenDeployed(curvesTokenSubject, tokenContract, name, symbol);
        return address(tokenContract);
    }