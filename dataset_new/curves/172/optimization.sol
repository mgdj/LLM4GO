function transferAllCurvesTokens(address to) external {
        if (to == address(this)) revert ContractCannotReceiveTransfer();
        address[] storage subjects = ownedCurvesTokenSubjects[msg.sender];
        uint256 x = subjects.length;
        for (uint256 i = 0; i < x; ) {
            uint256 amount = curvesTokenBalance[subjects[i]][msg.sender];
            if (amount != 0) {
                _transfer(subjects[i], msg.sender, to, amount);
            }
            unchecked{
                ++i;
            }
        }
    }