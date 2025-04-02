function setManager(address manager_, bool value) public payable onlyOwner {
        managers[manager_] = value;
    }