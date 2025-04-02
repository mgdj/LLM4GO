abstract contract Automator is Swapper, Ownable {
    uint256 internal constant Q64 = 2 ** 64;
    uint256 internal constant Q96 = 2 ** 96;

    uint32 private constant MIN_TWAP_SECONDS = 60; // 1 minute
    uint32 private constant MAX_TWAP_TICK_DIFFERENCE = 200; // 2%

    // admin events
    event OperatorChanged(address newOperator, bool active);
    event VaultChanged(address newVault, bool active);

    event WithdrawerChanged(address newWithdrawer);
    event TWAPConfigChanged(uint32 TWAPSeconds, uint16 maxTWAPTickDifference);

    // configurable by owner
    mapping(address => uint256) public operators;
    mapping(address => uint256) public vaults;