function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256,
        uint256,
        uint256,
        address,
        address payable,
        bytes memory,
        address
    ) external override {
        // Disallow transactions that use delegate call, unless explicitly
        // Require that a function selector exists.
        if (data.length < 4) {
            revert Errors.GuardPolicy_FunctionSelectorRequired();
        }
        // permitted by the protocol.
        if (operation == Enum.Operation.DelegateCall && !STORE.whitelistedDelegates(to)) {
            revert Errors.GuardPolicy_UnauthorizedDelegateCall(to);
        }

        // Fetch the hook to interact with for this transaction.
        address hook = STORE.contractToHook(to);
        bool isActive = STORE.hookOnTransaction(hook);

        // If a hook exists and is enabled, forward the control flow to the hook.
        if (hook != address(0) && isActive) {
            _forwardToHook(hook, msg.sender, to, value, data);
        }
        // If no hook exists, use basic tx check.
        else {
            _checkTransaction(msg.sender, to, data);
        }
    }