function _claim(
    address _token,
    address _receiver,
    uint8 _percentage,
    Exchange _exchange,
    bytes calldata _data
) internal returns (uint256 claimedAmount) {
    uint256 userStake = balances[msg.sender][_token];

    // Use assembly to check if userStake == 0
    assembly {
        if iszero(userStake) {
            mstore(0x00, 0x4e487b71) // Function selector for custom errors
            revert(0x00, 0x04)
        }
    }

    if (_token == ETH) {
        // Assembly to check if _token is ETH
        claimedAmount = userStake.mulDiv(totalLpETH, totalSupply);
        balances[msg.sender][_token] = 0;
        lpETH.safeTransfer(_receiver, claimedAmount);
    } else {
        uint256 userClaim = userStake * _percentage / 100;

        // Validate data with _validateData before proceeding
        _validateData(_token, userClaim, _exchange, _data);

        balances[msg.sender][_token] = userStake - userClaim;

        // Use the quote to swap token to ETH
        _fillQuote(IERC20(_token), userClaim, _data);

        // Convert swapped ETH to lpETH
        claimedAmount = address(this).balance;
        lpETH.deposit{value: claimedAmount}(_receiver);
    }

    emit Claimed(msg.sender, _token, claimedAmount);
}