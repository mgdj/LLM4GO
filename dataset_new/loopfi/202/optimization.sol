function setOwner(address _owner) external payable onlyAuthorized {
        owner = _owner;

        emit OwnerUpdated(_owner);
    }