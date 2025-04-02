Prompt_MAP_CONSTANT = {
    "1.1":'''functions guaranteed to revert when called by normal users can be marked payable.
If a function modifier such as onlyOwner is used, the function will revert if a normal user tries to pay the function. Marking the function as payable will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.
    ''',
    "1.2":'''use custom errors instead of revert strings to save gas.
You can first find the require or revert statement, if they revert a string, you can try to use custom error instead of it.But if they don't revert a string, consider make no change.
    ''',
    "1.3":'''Avoid declaring unused variables or unused internal function
You first find the location of the variable no use in the given information, and if that is the case, remove it.
    ''',
    "2.1":'''Splitting require() statements that use && saves gas.
When you find that the require statement's judgement has a continuous judgement of &&, you can split it into multiple require statements to save gas.
    ''',
    "2.2":'''Using unchecked blocks to save gas
If we know that our mathematics will be safe we could safe a little gas by using unchecked.
    example:
    if (_oldPTRate == _ptRate && _ibtRate > _oldIBTRate) {
-        newYieldInIBTRay = ibtOfPTInRay.mulDiv(_ibtRate - _oldIBTRate, _ibtRate);
+        unchecked {
+               uint256 ibtRateMinusOldIbtRate = _ibtRate - _oldIBTRate;
+        }
+        newYieldInIBTRay = ibtOfPTInRay.mulDiv(ibtRateMinusOldIbtRate, _ibtRate);
    function calculateSumAndProduct(uint256 n, uint256 multiplier) external pure returns (uint256 sum, uint256 product) {
        require(n < 2**128, "n is too large"); // Ensures n won't cause overflow
        require(multiplier < 2**128, "Multiplier is too large"); // Validates multiplier is safe
        sum = 0;
        product = 1;
        unchecked {
            for (uint256 i = 1; i <= n; i++) {
                sum += i; // Loop has a natural upper bound (n), no overflow risk
                product *= multiplier; // Pre-sanitized multiplier ensures safety
            }
        }
    }
    ''',
    # function calculateSumAndProduct(uint256 n, uint256 multiplier) external pure returns (uint256 sum, uint256 product) {
    #     require(n < 2**128, "n is too large"); // Ensures n won't cause overflow
    #     require(multiplier < 2**128, "Multiplier is too large"); // Validates multiplier is safe
    #     sum = 0;
    #     product = 1;
    #     unchecked {
    #         for (uint256 i = 1; i <= n; i++) {
    #             sum += i; // Loop has a natural upper bound (n), no overflow risk
    #             product *= multiplier; // Pre-sanitized multiplier ensures safety
    #         }
    #     }
    # }
    "2.3":'''++i costs less gas compared to i++ or i += 1 (same for --i vs i-- or i -= 1)
You find that unsigned int increases or decreases, and you can change i++ and i+=1 into ++i, i-- the same thing. While, there will be some situations you don't need to change. For example, a = i++; or a = functionA(i++);.
    ''',
    "2.4":'''Unnecessary casting or expression
Optimize Solidity code by avoiding unnecessary variable assignments, re-casting, or redundant expressions.In a function that returns multiple values, if only one value is required, avoid reassigning or re-casting both values unnecessarily.Also, there may be something about test.
    example:
    function getUints() public pure returns (uint, uint) {return (1, 2);}
    function funcA() public view {
        uint a; uint b; 
        (a, b) = getUints();
        uint g = gasleft();
-        (a, b) = getUints();
+        (a, ) = getUints();
        console.log(g - gasleft());
    }
    ''',
#     example:
#     function getUints() public pure returns (uint, uint) {return (1, 2);}
#     function funcA() public view {
#         uint a; uint b; 
#         (a, b) = getUints();
#         uint g = gasleft();
# -        (a, b) = getUints();
# +        (a, ) = getUints();
#         console.log(g - gasleft());
#     }
    "2.5":'''Using private rather than public for constants saves gas
You first need to find the variables with public and constant modifier, then convert it to private and rememeber to set the relevant read function to let the external contract read it.
    ''',
    "2.6":'''Use shift right/left instead of division/multiplication if possible.
In Solidity, optimizing gas costs is essential to ensure the efficiency and cost-effectiveness of your smart contracts. By using bitwise shift operations instead of division/multiplication, you can often achieve substantial gas savings. Remember to use caution and consider any potential constraints or issues related to signed integers when employing these optimizations.
    ''',
    "2.7":'''Comparison statement order adjustment.
You should first look for multiple conditional statements in the code, and then try to move the cheaper check or the early exit function check to the front.
    example1:
    function _isValidSafeOwner(address owner, address safe) internal view {
-        // Make sure only protocol-deployed safes can rent.
-        if (STORE.deployedSafes(safe) == 0) {
-            revert Errors.CreatePolicy_InvalidRentalSafe(safe);
-        }
         // Make sure the fulfiller is the owner of the recipient rental safe.
         if (!ISafe(safe).isOwner(owner)) {
             revert Errors.CreatePolicy_InvalidSafeOwner(owner, safe);
         }
+
+        // Make sure only protocol-deployed safes can rent.
+        if (STORE.deployedSafes(safe) == 0) {
+            revert Errors.CreatePolicy_InvalidRentalSafe(safe);
+        }
    example2:
-    return (_nonce < getMinNonce(_address) || nonceValues[addressAsKey][_nonce] > 0);
+    return (nonceValues[addressAsKey][_nonce] > 0 || _nonce < getMinNonce(_address));
    example3:
-    (uint256 _ptRate, uint256 _ibtRate) = _getPTandIBTRates(false);
    uint256 _oldIBTRate = ibtRateOfUser[_user];
-    uint256 _oldPTRate = ptRateOfUser[_user];
    if (_oldIBTRate != 0) {       
+        uint256 _oldPTRate = ptRateOfUser[_user];
+        (uint256 _ptRate, uint256 _ibtRate) = _getPTandIBTRates(false);
        _yieldOfUserInIBT = PrincipalTokenUtil._computeYield(
            _user,
            yieldOfUserInIBT[_user],
            _oldIBTRate,
            _ibtRate,
            _oldPTRate,
            _ptRate,
            yt
        );
    ''',
    
#     example1:
#     function _isValidSafeOwner(address owner, address safe) internal view {
# -        // Make sure only protocol-deployed safes can rent.
# -        if (STORE.deployedSafes(safe) == 0) {
# -            revert Errors.CreatePolicy_InvalidRentalSafe(safe);
# -        }
#          // Make sure the fulfiller is the owner of the recipient rental safe.
#          if (!ISafe(safe).isOwner(owner)) {
#              revert Errors.CreatePolicy_InvalidSafeOwner(owner, safe);
#          }
# +
# +        // Make sure only protocol-deployed safes can rent.
# +        if (STORE.deployedSafes(safe) == 0) {
# +            revert Errors.CreatePolicy_InvalidRentalSafe(safe);
# +        }
#     example2:
# -    return (_nonce < getMinNonce(_address) || nonceValues[addressAsKey][_nonce] > 0);
# +    return (nonceValues[addressAsKey][_nonce] > 0 || _nonce < getMinNonce(_address));
#     example3:
# -    (uint256 _ptRate, uint256 _ibtRate) = _getPTandIBTRates(false);
#     uint256 _oldIBTRate = ibtRateOfUser[_user];
# -    uint256 _oldPTRate = ptRateOfUser[_user];
#     if (_oldIBTRate != 0) {       
# +        uint256 _oldPTRate = ptRateOfUser[_user];
# +        (uint256 _ptRate, uint256 _ibtRate) = _getPTandIBTRates(false);
#         _yieldOfUserInIBT = PrincipalTokenUtil._computeYield(
#             _user,
#             yieldOfUserInIBT[_user],
#             _oldIBTRate,
#             _ibtRate,
#             _oldPTRate,
#             _ptRate,
#             yt
#         );
    "2.8":'''a = a + b is more gas effective than a += b for state variables(excluding mapping and arrays)
You first need to determine where the state variable(not an array or mapping) is written in the code, and when the state variable executes a+=b statement, you need to change it to a=a+b statement to save gas.
    ''',
    "2.9":'''Cache array length outside of loop
You should first check whether the array.length in the loop is cached, if not, then cache it.
    ''',
#     example:
#     uint[] myArray = [1, 2, 3, 4, 5];
# -    for (uint i = 0; i < myArray.length; i++) {
# +    uint arrayLength = myArray.length; 
# +    for (uint i = 0; i < arrayLength; i++)
    "2.10":'''Move require emit ahead
Optimize Solidity code by moving emit or require statements ahead of variable assignments or updates when possible. This prevents the creation of additional temporary variables to store the old state values before an update.
    example:
    function setPriorityTxMaxGasLimit(uint256 _newPriorityTxMaxGasLimit) external onlyStateTransitionManager { 
        require(_newPriorityTxMaxGasLimit <= MAX_GAS_PER_TRANSACTION, "n5");
+        emit NewPriorityTxMaxGasLimit(s.priorityTxMaxGasLimit, _newPriorityTxMaxGasLimit);
-        uint256 oldPriorityTxMaxGasLimit = s.priorityTxMaxGasLimit;
        s.priorityTxMaxGasLimit = _newPriorityTxMaxGasLimit;
-        emit NewPriorityTxMaxGasLimit(oldPriorityTxMaxGasLimit, _newPriorityTxMaxGasLimit);
    }
    ''',
    "2.11":'''Repetitive code optimization
You first need to find similar statements in the function, and then try to combine them with simpler statements or loop statements.
    ''',
    "3.1":'''Use calldata instead of memory for function arguments that do not get mutated
You should first find function arguments that do not need to be changed within the function. If its type is memory, you mark the data type as calldata. But its type is not memory(such as byte32 or address), skip it.
    ''',
    "3.2":'''state variables should be cached in stack variables rather than re-reading them from storage
You should first look for the location of the state variable in the function. If a variable is read multiple times or it is read once after it's written, you can consider set it as a local variable.
    ''',
#     example:
#     uint256 a;
#     function somefunction(uint256 x) public {
# -        a = x + 1;
# -        uint256 y = a + 1;
# +        uint256 tmp_a = x + 1;
# +        a = tmp_a;
# +        uint256 y = tmp_a + 1;
#     }
    "3.3":'''State variables only set in the constructor should be declared immutable & Use immutables variables directly instead of caching them in stack.
You should first find the variables set only in constructor and then set them immutable.
    ''',
    "3.4":'''Pack the variables into fewer storage slots by re-ordering the variables or reducing their sizes
You should first determine whether there is a situation in which these variables can reduce size, such as some variables about time, and then after reducing size of the variable, you need to determine whether you can adjust the order of the variables to make storage more space-saving. And of course you also have to think about what's going on inside the struct.
    exmaple:
-    uint256 public LastDistribution;
    uint256 public MinDistributionPeriod;
+    uint48 public LastDistribution;
    bool public LockedForDistribution;
    LastDistribution can be reduced to uint48 since it holds block number so uint48 is more than sufficient to hold any realistic block number of any blockchain.
    ''',
    "3.5":'''Do not declare local variables used only once.
You should first check all the local variables decleared in the code, for every variable, you must consider whether it's used in a loop.If its used in a loop or loop condition check, make no change. if it's not used in aloop and it used only once, you should avoid it.
    ''',
#     example:
# -        UniTwapPoolInfo memory uniTwapPoolInfoStruct = uniTwapPoolInfo[                          
# -            _tokenAddress                                                                        
# -        ];                                                                                       
# -                                                                                                 
# -        if (uniTwapPoolInfoStruct.oracle > ZERO_ADDRESS) {                                       
# +        if (uniTwapPoolInfo[_tokenAddress].oracle > ZERO_ADDRESS) {                              
#              revert AggregatorNotNecessary();                                                     
#          } 
    "3.6":'''check before updating state variable with same value.
You should first look for where to write the state variable, and then determine whether it is an assignment statement. If it is set in a constructor or initializer function, make no change. if it is an assignment statement, you need to check before updating state variable with same value.
    ''',
#     example:
#     function setApprovalForAll(address operator, bool approved) public {
# +        if (isApprovedForAll[msg.sender][operator] == approved) return;
#         isApprovedForAll[msg.sender][operator] = approved;
#         emit ApprovalForAll(msg.sender, operator, approved);
#     }
    "3.7":'''Using bools for storage incurs overhead,instead use uint256
You first need to find those state variables that refer to bool. To mitigate these gas costs, you can utilize uint256 values uint256(1) and uint256(2) to represent true and false respectively including the variables in mapping.
    ''',
    "3.8":'''Creating memory variable or emitting should be outside of loop
You should first determine if there is any new local variable or emit inside the loop of your code. At this point, you need to consider whether you need to move the emit and variable declaration statements out of the loop.
    ''',
#     example:
# +    uint myNumber;
#     for (uint i=0; i<10; i++) {
# -        uint myNumber = i*i;
# +        myNumber = i*i;
#     }
    "3.9":'''Cache state variables outside of loop
If you find a loop and in the loop, a state variable is read, you can consider whether to cache the state variables out of loop.
    example:
    uint256 fee;
    function somefunction() public {
+        uint256 _fee = fee;
        for (uint256 i = 0; i < items.length; ++i) {
-            if (fee != 0) {
+            if (_fee != 0) {
                //logic here
            }
        }
    }
    ''',
#     example:
#     uint256 fee;
#     function somefunction() public {
# +        uint256 _fee = fee;
#         for (uint256 i = 0; i < items.length; ++i) {
# -            if (fee != 0) {
# +            if (_fee != 0) {
#                 //logic here
#             }
#         }
#     }
    "4.1":'''Use assembly to check for zero,address(0),msg.sender
You should first determine if zero check, address(0) check  is present in your code, and if so try to change these statements to inline assembly.
    ''',
    "5.1":'''For solidty 0.8.12 or below, use != 0 instead of > 0 for unsigned integer comparison.
You first need to find the cases where 0 is compared. When 0 is compared with unsigned int, then if it uses a>0, it can be converted to a! =0 to save gas.
    '''
}
# If it is a self-incresement(decresement) statement, make no change.