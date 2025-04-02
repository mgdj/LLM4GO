function setEmergencyAdmin(address admin) external onlyOwner {
        emergencyAdmin = admin;
        emit SetEmergencyAdmin(admin);
    }