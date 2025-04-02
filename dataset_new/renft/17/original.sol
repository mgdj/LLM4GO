contract Create2Deployer {
    // Determine if an address has already been deployed.
    mapping(address => bool) public deployed;

    // Byte used to prevent collision with CREATE.
    bytes1 constant create2_ff = 0xff;
