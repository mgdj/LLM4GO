/// @notice Subtract two int256 bit LeftRight-encoded words; revert on overflow.
/// @param x the minuend
/// @param y the subtrahend
/// @return z the difference x - y
function sub(int256 x, int256 y) internal pure returns (int256 z) {
    unchecked {
        int256 left256 = int256(x.leftSlot()) - y.leftSlot();
        int128 left128 = int128(left256);
        int256 right256 = int256(x.rightSlot()) - y.rightSlot();
        int128 right128 = int128(right256);
        if (left128 != left256 || right128 != right256) revert Errors.UnderOverFlow();
        return z.toRightSlot(right128).toLeftSlot(left128);
    }
}