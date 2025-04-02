/// @notice params for execute()
struct ExecuteParams {
    uint256 tokenId; // tokenid to process
    bytes swapData; // if its a swap order - must include swap data
    uint128 liquidity; // liquidity the calculations are based on
    uint256 amountRemoveMin0; // min amount to be removed from liquidity
    uint256 amountRemoveMin1; // min amount to be removed from liquidity
    uint256 deadline; // for uniswap operations - operator promises fair value
    uint64 rewardX64; // which reward will be used for protocol, can be max configured amount (considering onlyFees)
}