function claim(uint256 amount) external {
    address tmp = treasuryAddress;
    require(
        allowance(tmp, msg.sender) >= amount, 
    );
    transferFrom(tmp, msg.sender, amount);
    emit TokensClaimed(msg.sender, amount);
}