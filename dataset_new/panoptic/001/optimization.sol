function afterTokenTransfer(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) internal override {
        uint256 len = ids.length
        for (uint256 i = 0; i < len; ) {
            registerTokenTransfer(from, to, ids[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }