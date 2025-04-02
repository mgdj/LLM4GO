function mint(uint256 tokenId, uint256 quantity) external {
        require(tokenId < _itemCount);
        uint256 price = allGameItemAttributes[tokenId].itemPrice * quantity;
        require(_neuronInstance.balanceOf(msg.sender) >= price, "Not enough NRN for purchase");
        require(
            allGameItemAttributes[tokenId].finiteSupply == false || 
            (
                allGameItemAttributes[tokenId].finiteSupply == true && 
                quantity <= allGameItemAttributes[tokenId].itemsRemaining
            )
        );
        require(
            dailyAllowanceReplenishTime[msg.sender][tokenId] <= block.timestamp || 
            quantity <= allowanceRemaining[msg.sender][tokenId]
        );

        _neuronInstance.approveSpender(msg.sender, price);
        bool success = _neuronInstance.transferFrom(msg.sender, treasuryAddress, price);
        if (success) {
            if (dailyAllowanceReplenishTime[msg.sender][tokenId] <= block.timestamp) {
                _replenishDailyAllowance(tokenId);
            }
            allowanceRemaining[msg.sender][tokenId] -= quantity;
            if (allGameItemAttributes[tokenId].finiteSupply) {
                allGameItemAttributes[tokenId].itemsRemaining -= quantity;
            }
            _mint(msg.sender, tokenId, quantity, bytes("random"));
            emit BoughtItem(msg.sender, tokenId, quantity);
        }
    }