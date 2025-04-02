function addRentalSafe(address safe) external onlyByProxy permissioned {
        // Get the new safe count.
        uint256 newSafeCount = totalSafes + 1;

        // Register the safe as deployed.
        deployedSafes[safe] = newSafeCount;

        // Increment nonce.
        totalSafes = newSafeCount;
    }