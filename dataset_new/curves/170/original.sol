function setManager(address manager_, bool value) public onlyOwner {
        managers[manager_] = value;
    }