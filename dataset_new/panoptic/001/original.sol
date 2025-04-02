function afterTokenTransfer(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal override {
        for (uint256 i = 0; i < ids.length; ) {
            registerTokenTransfer(from, to, ids[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }