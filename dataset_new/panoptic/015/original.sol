function setApprovalForAll(address operator, bool approved) public {
    isApprovedForAll[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
}