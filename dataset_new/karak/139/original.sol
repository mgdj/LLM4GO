function sort(address[] memory arr, uint256 left, uint256 right) private pure {
        if (left >= right) return;
        uint256 lastUnsortedInd = left;
        uint256 pivot = right;
        for (uint256 i = left; i < right; i++) {
            if (arr[i] <= arr[pivot]) {
                if (i != lastUnsortedInd) swap(arr, i, lastUnsortedInd);
                lastUnsortedInd++;
            }
        }
        swap(arr, pivot, lastUnsortedInd);
        if (lastUnsortedInd > left) {
            sort(arr, left, lastUnsortedInd - 1);
        }
        sort(arr, lastUnsortedInd, right);
    }