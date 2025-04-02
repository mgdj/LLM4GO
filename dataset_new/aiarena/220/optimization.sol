function mint(uint256 tokenId, uint256 quantity) external {
    // Check if tokenId is valid
    if (tokenId >= _itemCount) {
        revert InvalidTokenId(tokenId);
    }

    // Calculate the total price of the items
    uint256 price = allGameItemAttributes[tokenId].itemPrice * quantity;

    // Check if the user has enough NRN balance
    uint256 userBalance = _neuronInstance.balanceOf(msg.sender);
    if (userBalance < price) {
        revert InsufficientNRN(price, userBalance);
    }

    // Check if the supply is sufficient (for finite supply items)
    if (allGameItemAttributes[tokenId].finiteSupply && quantity > allGameItemAttributes[tokenId].itemsRemaining) {
        revert InsufficientSupply(quantity, allGameItemAttributes[tokenId].itemsRemaining);
    }

    // Check if the user's daily allowance allows the purchase
    if (quantity > allowanceRemaining[msg.sender][tokenId]) {
        revert AllowanceExceeded(quantity, allowanceRemaining[msg.sender][tokenId]);
    }
    if (dailyAllowanceReplenishTime[msg.sender][tokenId] > block.timestamp) {
        revert AllowanceExceeded(quantity, allowanceRemaining[msg.sender][tokenId]);
    }

    // Approve and transfer the NRN tokens for the purchase
    _neuronInstance.approveSpender(msg.sender, price);
    bool success = _neuronInstance.transferFrom(msg.sender, treasuryAddress, price);

    if (success) {
        // Replenish daily allowance if required
        if (dailyAllowanceReplenishTime[msg.sender][tokenId] <= block.timestamp) {
            _replenishDailyAllowance(tokenId);
        }

        // Decrease the user's remaining allowance and item supply
        allowanceRemaining[msg.sender][tokenId] = allowanceRemaining[msg.sender][tokenId] - quantity;
        if (allGameItemAttributes[tokenId].finiteSupply) {
            allGameItemAttributes[tokenId].itemsRemaining -= quantity;
        }

        // Mint the item(s) to the user
        _mint(msg.sender, tokenId, quantity, bytes("random"));
        emit BoughtItem(msg.sender, tokenId, quantity);
    }
}
error InvalidTokenId(uint256 tokenId);
error InsufficientNRN(uint256 required, uint256 available);
error InsufficientSupply(uint256 requested, uint256 remaining);
error AllowanceExceeded(uint256 requested, uint256 remaining);