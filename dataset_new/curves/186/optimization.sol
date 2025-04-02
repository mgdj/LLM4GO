function sellCurvesToken(address curvesTokenSubject, uint256 amount) public {
        uint256 supply = curvesTokenSupply[curvesTokenSubject];
        if (supply <= amount) revert LastTokenCannotBeSold();
        if (curvesTokenBalance[curvesTokenSubject][msg.sender] < amount) revert InsufficientBalance();
        unchecked{
            uint256 price = getPrice(supply - amount, amount);
        
            curvesTokenBalance[curvesTokenSubject][msg.sender] -= amount;
        }
        if(curvesTokenSupply[curvesTokenSubject] != supply - amount){
            curvesTokenSupply[curvesTokenSubject] = supply - amount;

        }

        _transferFees(curvesTokenSubject, false, price, amount, supply);
    }