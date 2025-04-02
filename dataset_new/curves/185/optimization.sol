function _buyCurvesToken(address curvesTokenSubject, uint256 amount) internal {
        uint256 supply = curvesTokenSupply[curvesTokenSubject];
        if (!(supply != 0 || curvesTokenSubject == msg.sender)) revert UnauthorizedCurvesTokenSubject();

        uint256 price = getPrice(supply, amount);
        (, , , , uint256 totalFee) = getFees(price);

        if (msg.value < price + totalFee) revert InsufficientPayment();

        curvesTokenBalance[curvesTokenSubject][msg.sender] += amount;
        if(curvesTokenSupply[curvesTokenSubject] != supply + amount){
            curvesTokenSupply[curvesTokenSubject] = supply + amount;
        }
        _transferFees(curvesTokenSubject, true, price, amount, supply);

        // If is the first token bought, add to the list of owned tokens
        unchecked{
            if (curvesTokenBalance[curvesTokenSubject][msg.sender] - amount == 0) {
                _addOwnedCurvesTokenSubject(msg.sender, curvesTokenSubject);
            }
        }
    }