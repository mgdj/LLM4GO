function setupAirdrop(address[] calldata recipients, uint256[] calldata amounts) external {
        require(isAdmin[msg.sender]);
        uint256 recipientsLength = recipients.length;
        require(recipientsLength == amounts.length);
        for (uint32 i = 0; i < recipientsLength; i++) {
            _approve(treasuryAddress, recipients[i], amounts[i]);
        }
    }