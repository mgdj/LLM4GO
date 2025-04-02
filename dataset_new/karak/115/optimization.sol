function registerOperatorToDSS(IDSS dss, bytes calldata registrationHookData)
        external
        whenFunctionNotPaused(Constants.PAUSE_CORE_REGISTER_TO_DSS)
        nonReentrant
    {
        address operator = msg.sender;
        CoreLib.Storage storage self = _self();
        if (!self.isDSSRegistered(dss)) revert DSSNotRegistered();
        self.registerOperatorToDSS(dss, operator, registrationHookData);
        emit RegisteredOperatorToDSS(operator, address(dss));
    }