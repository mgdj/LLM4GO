function setOwner(address _owner) external onlyAuthorized {
        owner = _owner;

        emit OwnerUpdated(_owner);
    }