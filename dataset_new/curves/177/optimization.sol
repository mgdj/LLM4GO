function _transferFees(
        address curvesTokenSubject,
        bool isBuy,
        uint256 price,
        uint256 amount,
        uint256 supply
    ) internal {
        (uint256 protocolFee, uint256 subjectFee, uint256 referralFee, uint256 holderFee, ) = getFees(price);
        {
            bool referralDefined = referralFeeDestination[curvesTokenSubject] != address(0);
            {
                address firstDestination = isBuy ? feesEconomics.protocolFeeDestination : msg.sender;
                uint256 buyValue = referralDefined ? protocolFee : protocolFee + referralFee;
                uint256 sellValue = price - protocolFee - subjectFee - referralFee - holderFee;
                (bool success1, ) = firstDestination.call{value: isBuy ? buyValue : sellValue}("");
                if (!success1) revert CannotSendFunds();
            }
            {
                (bool success2, ) = curvesTokenSubject.call{value: subjectFee}("");
                if (!success2) revert CannotSendFunds();
            }
            {
                (bool success3, ) = referralDefined
                    ? referralFeeDestination[curvesTokenSubject].call{value: referralFee}("")
                    : (true, bytes(""));
                if (!success3) revert CannotSendFunds();
            }

            if (feesEconomics.holdersFeePercent != 0 && address(feeRedistributor) != address(0)) {
                feeRedistributor.onBalanceChange(curvesTokenSubject, msg.sender);
                feeRedistributor.addFees{value: holderFee}(curvesTokenSubject);
            }
        }
        emit Trade(
            msg.sender,
            curvesTokenSubject,
            isBuy,
            amount,
            price,
            protocolFee,
            subjectFee,
            isBuy ? supply + amount : supply - amount
        );
    }