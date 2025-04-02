function _decreaseDeposit(address token, uint256 amount) internal {
         // Directly decrease the synced balance.
        if (amount > 0){
            balanceOf[token] -= amount;
        }
     }