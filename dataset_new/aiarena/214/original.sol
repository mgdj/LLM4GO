function claim(uint256 amount) external {
        require(
            allowance(treasuryAddress, msg.sender) >= amount, 
            "ERC20: claim amount exceeds allowance"
        );
        transferFrom(treasuryAddress, msg.sender, amount);
        emit TokensClaimed(msg.sender, amount);
    }