function createGameItem(
        string memory name_,
        string memory tokenURI,
        bool finiteSupply,
        bool transferable,
        uint256 itemsRemaining,
        uint256 itemPrice,
        uint16 dailyAllowance
    ) 
        public 
    {
        require(isAdmin[msg.sender]);
        allGameItemAttributes.push(
            GameItemAttributes(
                name_,
                finiteSupply,
                transferable,
                itemsRemaining,
                itemPrice,
                dailyAllowance
            )
        );
        if (!transferable) {
          emit Locked(_itemCount);
        }
        setTokenURI(_itemCount, tokenURI);
        _itemCount += 1;
    }