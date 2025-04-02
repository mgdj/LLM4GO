function _decreaseDeposit(address token, uint256 amount) internal {
         // Directly decrease the synced balance.
        balanceOf[token] -= amount;
     }