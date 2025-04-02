function pause() external onlyRole(PAUSER_ROLE) whenNotPaused {
    _pause();
  }