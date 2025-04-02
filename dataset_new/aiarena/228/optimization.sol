function pickWinner(uint256[] calldata winners) external {
    // Check if the caller is an admin
    if (!isAdmin[msg.sender]) {
        revert NotAdmin();
    }

    // Check if the number of winners is correct
    if (winners.length != winnersPerPeriod) {
        revert IncorrectWinnerCount(winners.length, winnersPerPeriod);
    }

    // Check if the selection for the current round is already complete
    if (isSelectionComplete[roundId]) {
        revert SelectionAlreadyComplete(roundId);
    }

    // Initialize memory array to store the winner addresses
    uint256 winnersLength = winners.length;
    address[] memory currentWinnerAddresses = new address[](winnersLength);

    // Process each winner
    for (uint256 i = 0; i < winnersLength;) {
        currentWinnerAddresses[i] = _fighterFarmInstance.ownerOf(winners[i]);

        // Deduct points and reset fighter points to zero
        totalPoints = totalPoints - fighterPoints[winners[i]];
        fighterPoints[winners[i]] = 0;
        unchecked{
            ++i;
        }
    }

    // Store winner addresses and mark the selection as complete
    winnerAddresses[roundId] = currentWinnerAddresses;
    isSelectionComplete[roundId] = true;

    // Move to the next round
    roundId = roundId + 1;
}

error NotAdmin();
error IncorrectWinnerCount(uint256 provided, uint256 expected);
error SelectionAlreadyComplete(uint256 roundId);