import os
from slither.slither import Slither  
from slither.slithir.convert import convert_expression
# 设置目标文件夹路径
directory_path = '/nasdata/ruanyijie/gas_optimization/solidity_files/2022-12-escher/'

slither = Slither(directory_path)
# 获取所有以.sol结尾的文件的绝对路径
sol_files = []
for root, dirs, files in os.walk(directory_path+'contracts/'):
    for file in files:
        if file.endswith('.sol'):
            sol_files.append(os.path.join(root, file))
for contract in slither.contracts:
    print(contract.name)
    for function in contract.functions:

        print(function.name)
# 遍历这些路径
# for sol_file in sol_files:
#     print(f"Processing file: {sol_file}")
#     txt_file = sol_file.replace('.sol', '.txt')
#     with open(txt_file,'w') as f:
#         slither = Slither(sol_file)  
        
#         for contract in slither.contracts: 
#             # print(contract.modifiers)
#             f.write(f'Contract:{contract.name}\n') 
#             entry_point = contract.get_function_from_signature("entry_point()")
#             if entry_point != None:

#                 all_calls = entry_point.all_internal_calls()

#                 all_calls_formated = [f.canonical_name for f in all_calls]

#                 # Print the result
#                 f.write(f"From entry_point the functions reached are {all_calls_formated}\n")
#             else:
#                 f.write("From entry_point no functions reached\n")
#             for function in contract.functions:
#                 f.write(f'Function: {function.name}\n')
                
#                 read_vars = ', '.join([v.name for v in function.state_variables_read])
#                 written_vars = ', '.join([v.name for v in function.state_variables_written])
                
#                 f.write(f'\tRead: {read_vars}\n')
#                 f.write(f'\tWritten: {written_vars}\n')
                
#                 for node in function.nodes:
#                     f.write(f'Node_type:{node.type}  Expression:{node.expression}\n')
#                     node_read_state_vars = ', '.join([v.name for v in node.state_variables_read])
#                     node_written_state_vars = ', '.join([v.name for v in node.state_variables_written])
#                     node_read_vars = ', '.join([v.name for v in node.variables_read])
#                     node_written_vars = ', '.join([v.name for v in node.variables_written])
#                     f.write(f'\tstate_Read: {node_read_state_vars}\n')
#                     f.write(f'\tstate_Written: {node_written_state_vars}\n')
#                     f.write(f'\tRead: {node_read_vars}\n')
#                     f.write(f'\tWritten: {node_written_vars}\n')
#                     if node.expression:
#                         irs = convert_expression(node.expression, node)
#                         f.write("IR expressions:\n")
#                         for ir in irs:
#                             f.write(f"\t{ir}\n")
                    
            

            # print(f'\tRead: {read_vars}')
            # print(f'\tWritten: {written_vars}')