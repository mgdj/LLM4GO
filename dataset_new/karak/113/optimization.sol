    function hasDuplicates(address[] memory arr) external pure returns (bool) {
        sortArr(arr);
        if (arr.length == 0) return false;
        uint256 x = arr.length
        for (uint256 i = 0; i < x - 1; i++) {
            if (arr[i] == arr[i + 1]) return true;
        }
        return false;
    }