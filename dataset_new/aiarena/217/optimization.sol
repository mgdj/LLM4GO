function createGameItem(
        string calldata name_,
        string calldata tokenURI,
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
        uint256 x = _itemCount;
        if (!transferable) {
          emit Locked(x);
        }
        setTokenURI(x, tokenURI);
        _itemCount = x + 1;
    }