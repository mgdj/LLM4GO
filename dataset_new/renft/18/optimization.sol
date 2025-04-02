contract Kernel {
    // Admin addresses.
    address public executor;
    address public admin;

    // Module Management.
    Keycode[] public allKeycodes;
    mapping(Keycode => Module) public getModuleForKeycode; // get contract for module keycode.
    mapping(Module => Keycode) public getKeycodeForModule; // get module keycode for contract.

    // Module dependents data. Manages module dependencies for policies.
    mapping(Keycode => Policy[]) public moduleDependents;
    mapping(Keycode => mapping(Policy => uint256)) public getDependentIndex;

    // Module <> Policy Permissions. Keycode -> Policy -> Function Selector -> Permission.
    mapping(Keycode => mapping(Policy => mapping(bytes4 => uint256)))
        public modulePermissions; // for policy addr, check if they have permission to call the function in the module.

    // List of all active policies.
    Policy[] public activePolicies;
    mapping(Policy => uint256) public getPolicyIndex;

    // Policy roles data.
    mapping(address => mapping(Role => uint256)) public hasRole;
    mapping(Role => uint256) public isRole;
