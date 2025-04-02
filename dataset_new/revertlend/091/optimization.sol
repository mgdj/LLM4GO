function setEmergencyAdmin(address admin) external onlyOwner {
    if(emergencyAdmin!=admin){
        emergencyAdmin = admin;
        emit SetEmergencyAdmin(admin);
    }
        
}