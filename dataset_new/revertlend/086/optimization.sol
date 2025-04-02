function _routerSwap(RouterSwapParams memory params)
    internal
    returns (uint256 amountInDelta, uint256 amountOutDelta)
{
    if (params.amountIn != 0 && params.swapData.length != 0 && address(params.tokenOut) != address(0)) {
        uint256 balanceInBefore = params.tokenIn.balanceOf(address(this));
        uint256 balanceOutBefore = params.tokenOut.balanceOf(address(this));

        // get router specific swap data
        (address router, bytes memory routerData) = abi.decode(params.swapData, (address, bytes));

        if (router == zeroxRouter) {
            ZeroxRouterData memory data = abi.decode(routerData, (ZeroxRouterData));
            // approve needed amount
            SafeERC20.safeApprove(params.tokenIn, data.allowanceTarget, params.amountIn);
            // execute swap
            (bool success,) = zeroxRouter.call(data.data);
            if (!success) {
                revert SwapFailed();
            }
            // reset approval
            SafeERC20.safeApprove(params.tokenIn, data.allowanceTarget, 0);
        } else if (router == universalRouter) {
            UniversalRouterData memory data = abi.decode(routerData, (UniversalRouterData));
            // tokens are transfered to Universalrouter directly (data.commands must include sweep action!)
            SafeERC20.safeTransfer(params.tokenIn, universalRouter, params.amountIn);
            IUniversalRouter(universalRouter).execute(data.commands, data.inputs, data.deadline);
        } else {
            revert WrongContract();
        }

        amountInDelta = balanceInBefore - params.tokenIn.balanceOf(address(this));
        amountOutDelta = params.tokenOut.balanceOf(address(this)) - balanceOutBefore;

        // amountMin slippage check
        if (amountOutDelta < params.amountOutMin) {
            revert SlippageError();
        }

        // event for any swap with exact swapped value
        emit Swap(address(params.tokenIn), address(params.tokenOut), amountInDelta, amountOutDelta);
    }
}