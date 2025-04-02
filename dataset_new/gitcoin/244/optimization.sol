function pause() external payable onlyRole(PAUSER_ROLE) whenNotPaused {
    _pause();
  }