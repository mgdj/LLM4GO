/// @notice Whenever a token is recieved it either creates a new loan, or modifies an existing one when in transform mode.
/// @inheritdoc IERC721Receiver
function onERC721Received(address, address from, uint256 tokenId, bytes calldata data)
    external
    override
    returns (bytes4)
{
    // only Uniswap v3 NFTs allowed - sent from other contract
    if (msg.sender != address(nonfungiblePositionManager) || from == address(this)) {
        revert WrongContract();
    }

    (uint256 debtExchangeRateX96, uint256 lendExchangeRateX96) = _updateGlobalInterest();

    if (transformedTokenId == 0) {
        address owner = from;
        if (data.length > 0) {
            owner = abi.decode(data, (address));
        }
        loans[tokenId] = Loan(0);

        _addTokenToOwner(owner, tokenId);
        emit Add(tokenId, owner, 0);
    } else {
        uint256 oldTokenId = transformedTokenId;

        // if in transform mode - and a new position is sent - current position is replaced and returned
        if (tokenId != oldTokenId) {
            address owner = tokenOwner[oldTokenId];

            // set transformed token to new one
            transformedTokenId = tokenId;

            // copy debt to new token
            loans[tokenId] = Loan(loans[oldTokenId].debtShares);

            _addTokenToOwner(owner, tokenId);
            emit Add(tokenId, owner, oldTokenId);

            // clears data of old loan
            _cleanupLoan(oldTokenId, debtExchangeRateX96, lendExchangeRateX96, owner);

            // sets data of new loan
            _updateAndCheckCollateral(
                tokenId, debtExchangeRateX96, lendExchangeRateX96, 0, loans[tokenId].debtShares
            );
        }
    }

    return IERC721Receiver.onERC721Received.selector;
}