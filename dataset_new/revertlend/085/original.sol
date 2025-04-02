// transfers token (or unwraps WETH and sends ETH)
function _transferToken(address to, IERC20 token, uint256 amount, bool unwrap) internal {
    if (address(weth) == address(token) && unwrap) {
        weth.withdraw(amount);
        (bool sent,) = to.call{value: amount}("");
        if (!sent) {
            revert EtherSendFailed();
        }
    } else {
        SafeERC20.safeTransfer(token, to, amount);
    }
}