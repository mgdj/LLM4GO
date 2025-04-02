function deposit(address curvesTokenSubject, uint256 amount) public {
        if (amount % 1 ether != 0) revert NonIntegerDepositAmount();

        address externalToken = externalCurvesTokens[curvesTokenSubject].token;
        uint256 tokenAmount = amount / 1 ether;

        if (externalToken == address(0)) revert TokenAbsentForCurvesTokenSubject();
        if (amount > CurvesERC20(externalToken).balanceOf(msg.sender)) revert InsufficientBalance();
        if (tokenAmount > curvesTokenBalance[curvesTokenSubject][address(this)]) revert InsufficientBalance();

        CurvesERC20(externalToken).burn(msg.sender, amount);
        _transfer(curvesTokenSubject, address(this), msg.sender, tokenAmount);
    }