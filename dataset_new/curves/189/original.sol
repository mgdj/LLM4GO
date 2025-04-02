function buyCurvesTokenWithName(
        address curvesTokenSubject,
        uint256 amount,
        string memory name,
        string memory symbol
    ) public payable {
        uint256 supply = curvesTokenSupply[curvesTokenSubject];
        if (supply != 0) revert CurveAlreadyExists();

        _buyCurvesToken(curvesTokenSubject, amount);
        _mint(curvesTokenSubject, name, symbol);
    }