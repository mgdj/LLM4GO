function mint(address to, uint256 amount) public virtual {
    // Check if the total supply would exceed the maximum allowed supply
    if (totalSupply() + amount >= MAX_SUPPLY) {
        revert MaxSupplyExceeded(totalSupply(), MAX_SUPPLY);
    }

    // Check if the caller has the MINTER_ROLE
    if (!hasRole(MINTER_ROLE, msg.sender)) {
        revert NotMinter(msg.sender);
    }

    // Proceed with minting
    _mint(to, amount);
}

error MaxSupplyExceeded(uint256 currentSupply, uint256 maxSupply);
error NotMinter(address caller);