function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes calldata data
) public {
    if (msg.sender != from && !isApprovedForAll[from][msg.sender]) revert NotAuthorized();

    balanceOf[from][id] = balanceOf[from][id] - amount;

    // balance will never overflow
    unchecked {
        balanceOf[to][id] = balanceOf[to][id] + amount;
    }
    uint256 length = ids.length;
    for (uint256 i = 0; i < length; ) {
        id = ids[i];
        amount = amounts[i];
        balanceOf[from][id] = balanceOf[from][id] - amount;
        unchecked {
            balanceOf[to][id] = balanceOf[to][id] + amount;
        }
        unchecked {
            ++i;
        }
    }
    afterTokenTransfer(from, to, id, amount);

    emit TransferSingle(msg.sender, from, to, id, amount);

    if (to.code.length != 0) {
        if (
            ERC1155Holder(to).onERC1155Received(msg.sender, from, id, amount, data) !=
            ERC1155Holder.onERC1155Received.selector
        ) {
            revert UnsafeRecipient();
        }
    }
}