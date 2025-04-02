abstract contract ERC1155 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when only a single token is transferred
    /// @param operator the user who initiated the transfer
    /// @param from the user who sent the tokens
    /// @param to the user who received the tokens
    /// @param id the ERC1155 token id
    /// @param amount the amount of tokens transferred
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    /// @notice Emitted when multiple tokens are transferred from one user to another
    /// @param operator the user who initiated the transfer
    /// @param from the user who sent the tokens
    /// @param to the user who received the tokens
    /// @param ids the ERC1155 token ids
    /// @param amounts the amounts of tokens transferred
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    /// @notice Emitted when an operator is approved to transfer all tokens on behalf of a user
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    // emitted when a user attempts to transfer tokens they do not own nor are approved to transfer
    error NotAuthorized();

    // emitted when an attempt is made to initiate a transfer to a recipient that fails to signal support for ERC1155
    error UnsafeRecipient();

    /*//////////////////////////////////////////////////////////////
                             ERC1155 STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Token balances for each user
    /// @dev indexed by user, then by token id
    mapping(address account => mapping(uint256 tokenId => uint256 balance)) public balanceOf;

    /// @notice Approved addresses for each user
    /// @dev indexed by user, then by operator
    /// @dev operator is approved to transfer all tokens on behalf of user
    mapping(address owner => mapping(address operator => uint256 approvedForAll))
        public isApprovedForAll;