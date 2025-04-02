function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes calldata data
) public {
    if (!(msg.sender == from || isApprovedForAll[from][msg.sender])) revert NotAuthorized();

    balanceOf[from][id] -= amount;

    // balance will never overflow
    unchecked {
        balanceOf[to][id] += amount;
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