function _addOwnedCurvesTokenSubject(address owner_, address curvesTokenSubject) internal {
        address[] storage subjects = ownedCurvesTokenSubjects[owner_];
        uint256 x = subjects.length;
        for (uint256 i = 0; i < x; ) {
            if (subjects[i] == curvesTokenSubject) {
                return;
            }
            unchecked{++i;}
        }
        subjects.push(curvesTokenSubject);
    }