function executeWithPermit(uint256 tokenId, Instructions memory instructions, uint8 v, bytes32 r, bytes32 s)
        public
        returns (uint256 newTokenId)
    {
        if (nonfungiblePositionManager.ownerOf(tokenId) != msg.sender) {
            revert Unauthorized();
        }

        nonfungiblePositionManager.permit(address(this), tokenId, instructions.deadline, v, r, s);
        return execute(tokenId, instructions);

        // NOTE: previous operator can not be reset as operator set by permit can not change operator - so this operator will stay until reset
    }