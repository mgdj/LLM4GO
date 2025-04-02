function buyCurvesTokenForPresale(
        address curvesTokenSubject,
        uint256 amount,
        uint256 startTime,
        bytes32 merkleRoot,
        uint256 maxBuy
    ) public payable onlyTokenSubject(curvesTokenSubject) {
        if (curvesTokenSupply[curvesTokenSubject] != 0) revert CurveAlreadyExists();
        if (startTime <= block.timestamp) revert InvalidPresaleStartTime();
        if(presalesMeta[curvesTokenSubject].startTime = startTime){
            presalesMeta[curvesTokenSubject].startTime = startTime;
        }
        if(presalesMeta[curvesTokenSubject].merkleRoot){
            presalesMeta[curvesTokenSubject].merkleRoot = merkleRoot;
        }
        
        presalesMeta[curvesTokenSubject].maxBuy = (maxBuy == 0 ? type(uint256).max : maxBuy);

        _buyCurvesToken(curvesTokenSubject, amount);
    }