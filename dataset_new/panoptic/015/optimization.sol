function setApprovalForAll(address operator, bool approved) public {
    if (isApprovedForAll[msg.sender][operator] != approved) {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);  
    }
    
}