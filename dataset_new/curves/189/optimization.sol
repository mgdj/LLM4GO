function buyCurvesTokenWithName(
        address curvesTokenSubject,
        uint256 amount,
        string calldata name,
        string calldata symbol
    ) public payable {
        if (curvesTokenSupply[curvesTokenSubject] != 0) revert CurveAlreadyExists();

        _buyCurvesToken(curvesTokenSubject, amount);
        _mint(curvesTokenSubject, name, symbol);
    }