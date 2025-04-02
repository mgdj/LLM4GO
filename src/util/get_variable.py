import re

def extract_public_constant_variables(solidity_code,contract_name = None):
    # 匹配合约内容部分，允许继承（如 `contract Curves is CurvesErrors, Security`）
    if contract_name:
        # 匹配指定的合约名称
        contract_pattern = rf'contract\s+{contract_name}\s*(?:is\s*[^\{{]+)?\{{([\s\S]*?)\}}'
    else:
        # 匹配所有合约
        contract_pattern = r'contract\s+\w+\s*(?:is\s*[^\{]+)?\{([\s\S]*?)}'
    
    # 查找合约体
    contract_body_match = re.search(contract_pattern, solidity_code)
    if contract_body_match:
        contract_body = contract_body_match.group(1)
    else:
        return []
    
    # 只匹配带有 public 和 constant 的全局变量
    constant_variable_pattern = r'\b(?:uint256|int256|uint|int|string|address|bool|mapping\s*\([^\)]+\s*=>\s*[^\)]+\))\s+public\s+constant\s+\w+\s*=\s*[^;]+;'
    
    # 提取所有符合条件的全局变量
    constant_variables = re.findall(constant_variable_pattern, contract_body)
    
    return constant_variables

def get_public_constant_variables(file_path,contract_name):
    with open(file_path,'r') as f:
        content = f.read()
    public_constant_variables = extract_public_constant_variables(content,contract_name)
    # 打印提取到的 public constant 变量

    #2.5
    print(public_constant_variables)
    if len(public_constant_variables) >= 0:
        print(f'there may be a problem : Using private rather than public for constants saves gas in contract {contract_name}')
        return True
    return False
    # for var in public_constant_variables:
    #     print(var)
    

#test
# file_path = '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-01-curves/contracts/Curves.sol'
# contract_name = 'Curves'
# get_public_constant_variables(file_path,contract_name)