function _deployERC20(
        address curvesTokenSubject,
        string memory name,
        string memory symbol
    ) internal returns (address) {
        // If the token's symbol is CURVES, append a counter value
        if (keccak256(bytes(symbol)) == keccak256(bytes(DEFAULT_SYMBOL))) {
            _curvesTokenCounter += 1;
            name = string(abi.encodePacked(name, " ", Strings.toString(_curvesTokenCounter)));
            symbol = string(abi.encodePacked(symbol, Strings.toString(_curvesTokenCounter)));
        }

        if (symbolToSubject[symbol] != address(0)) revert InvalidERC20Metadata();

        address tokenContract = CurvesERC20Factory(curvesERC20Factory).deploy(name, symbol, address(this));

        externalCurvesTokens[curvesTokenSubject].token = tokenContract;
        externalCurvesTokens[curvesTokenSubject].name = name;
        externalCurvesTokens[curvesTokenSubject].symbol = symbol;
        externalCurvesToSubject[tokenContract] = curvesTokenSubject;
        symbolToSubject[symbol] = curvesTokenSubject;

        emit TokenDeployed(curvesTokenSubject, tokenContract, name, symbol);
        return address(tokenContract);
    }