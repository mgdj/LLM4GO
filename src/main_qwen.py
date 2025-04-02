import os
import re
import subprocess
from slither.slither import Slither  
from slither.slithir.convert import convert_expression
from openai import OpenAI
from tenacity import retry, stop_after_attempt, wait_fixed
import util.dot_solve
import util.function_modifier
import util.get_variable
import util.prompt
from util.dot_solve import get_message
from util.function_modifier import function_modifier_check
from util.get_variable import get_public_constant_variables
from util.prompt import Prompt_MAP_CONSTANT

def execute_command_and_save(command, output_file):
    try:
        # 执行命令，并将输出保存到文件
        with open(output_file, 'w') as file:
            result = subprocess.run(command, shell=True, stdout=file, stderr=subprocess.STDOUT, text=True)
            file.flush()

        # 检查命令是否执行成功
        if result.returncode != 0:
            print(f"Command failed with return code: {result.returncode}")
            print(f"Error: {result.stderr}")
        else:
            print(f"Command executed successfully. Output saved to {output_file}")
    except Exception as e:
        print(f"An error occurred while executing the command: {e}")



def loop_condition_analysis(sol_file,contract_name,function,directory):
    # for node in function.nodes:
    problem_in_loop = get_message(sol_file,contract_name,function,directory)
    return problem_in_loop

def is_two_mi(num):
    a = num
    while a%2 == 0:
        a /= 2
    if a==1:
        return True
    else:
        return False
    

def is_int(s):
    try:
        int(s)
        return True
    except ValueError:
        return False
    
# @retry(stop=stop_after_attempt(3), wait=wait_fixed(2))
def gpt_check_contract(content,problems,result_path):
    hint_message = ''
    for index,problem in enumerate(problems):
        hint_message+= str(index+1) +'.' + Prompt_MAP_CONSTANT[problem]
    print("hint message:")
    print(hint_message)
    print("content:")
    print(content)
    print('path:')
    print(result_path)
    client = OpenAI(
        api_key='sk-4a6fc66e30614e44bf53130bf15ba2e6',
        base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
        timeout=120
    )
    try:
        chat_completion = client.chat.completions.create(
            model="qwen-plus",
            messages=[
                {"role": "system", "content": "You are an expert in Solidity programming and gas optimization, capable of providing detailed recommendations and optimized code snippets.There are serveral kinds of optimizations may appear in the code.\n"+hint_message},
                {"role": "user", "content": "Can you help me optimize the following Solidity code to save more gas? The code is mainly the state variables in a contract. For each item, can you give your reasoning process and reasoning results at each step?finnaly please provide only the optimized code as the result, without recommendations or explanations.Ensure that the code modifications are made to the existing code without importing additional libraries and adding unnecessary functions.\n"+content}
            ],
            # stream 必须设置为 True，否则会报错
            temperature=0
        )
    except Exception as e:
        # 捕获所有异常并跳过
        print(f"An error occurred: {e}")
        print("Skipping this request and moving to the next one.")
        return
    with open(result_path, 'w') as file:
        # 将字符串写入文件
        file.write(chat_completion.choices[0].message.content)

# @retry(stop=stop_after_attempt(3), wait=wait_fixed(2))
def gpt_check_function(content,problems,result_path):
    hint_message = '    '
    for index,problem in enumerate(problems):
        hint_message+= str(index+1) +'.' + Prompt_MAP_CONSTANT[problem]
    print(hint_message)
    print(content)
    print(result_path)
    client = OpenAI(
        api_key='sk-4a6fc66e30614e44bf53130bf15ba2e6',
        base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
        timeout=120
    )
    try:
        chat_completion = client.chat.completions.create(
            model="qwen-plus",
            messages=[
                {"role": "system", "content": "You are an expert in Solidity programming and gas optimization, capable of providing detailed recommendations and optimized code snippets.There are serveral kinds of optimizations may appear in the code.\n"+hint_message},
                {"role": "user", "content": "Can you help me optimize the following Solidity code to save more gas? The code is a function in contract. For each item, can you give your reasoning process and reasoning results at each step? finnaly please provide the optimized code as the result, without recommendations or explanations. You should check items obove carefully. Ensure that the code modifications are made to the existing code without importing additional libraries and adding more functions.If you think there is nothing to optimization, just make no change.\n"+content}
            ],
            temperature=0
        )
    except Exception as e:
        # 捕获所有异常并跳过
        print(f"An error occurred: {e}")
        print("Skipping this request and moving to the next one.")
        return
    with open(result_path, 'w') as file:
        # 将字符串写入文件
        file.write(chat_completion.choices[0].message.content)

def find_sol_files(directory):
    sol_files = []
    # 遍历指定目录下的所有文件和文件夹
    # for file_name in os.listdir(directory):
    #     file_path = os.path.join(directory, file_name)
    #     # 如果是文件且扩展名是.sol
    #     if os.path.isfile(file_path) and file_name.endswith('.sol'):
    #         sol_files.append(file_path)
    for d in directory:
        for file in os.listdir(d):  # 遍历当前目录
            if file.endswith('.sol') and os.path.isfile(os.path.join(d, file)):
                sol_files.append(os.path.join(d, file))
    return sol_files
# 设置目标文件夹路径
directory = '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-01-renft/smart-contracts/'
directory_path = ['/nasdata/ruanyijie/gas_optimization/solidity_files/2024-01-renft/smart-contracts/src/','/nasdata/ruanyijie/gas_optimization/solidity_files/2024-01-renft/smart-contracts/src/policies/','/nasdata/ruanyijie/gas_optimization/solidity_files/2024-01-renft/smart-contracts/src/modules/']
result_path = '/nasdata/ruanyijie/gas_optimization/src/result_qwen/renft/'
if not os.path.exists(result_path):
    os.makedirs(result_path)
# 获取所有以.sol结尾的文件的绝对路径
# sol_files = []
# for root, dirs, files in os.walk(directory_path):
#     for file in files:
#         if file.endswith('.sol'):
#             sol_files.append(os.path.join(root, file))
sol_files = find_sol_files(directory_path)
print(sol_files)
# 遍历这些路径function
slither = Slither(directory)
command = 'slither '+directory+' --print function-summary'
output_file = './function-summary.txt'
execute_command_and_save(command,output_file)
for sol_file in sol_files:
    # if sol_file == '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-01-curves/contracts/Curves.sol':
    #     continue   
    contracts_in_sol_file = []
    with open(sol_file,'r') as f:
        sol_content = f.readlines()
    
    version = ''
    for line in sol_content:
        if line.startswith('pragma solidity'):
            result = re.split(r'[ ;]+', line)
            version = result[2]
        if line.startswith('contract ') or line.startswith('interface ') or line.startswith('library '):
            contract_name = line.split(' ')[1]
            contracts_in_sol_file.append(contract_name)
        if line.startswith('abstract contract '):
            contract_name = line.split(' ')[2]
            contracts_in_sol_file.append(contract_name)
    # print(version)
    print(contracts_in_sol_file)
    # slither = Slither(sol_file)  
    # print(sol_file)
    # print(len(slither.contracts))
    contracts_scanned = []

    for contract in slither.contracts: 
        # entry_point = contract.get_function_from_signature("entry_point()")
        # if entry_point != None:

        #     all_calls = entry_point.all_internal_calls()

        #     all_calls_formated = [f.canonical_name for f in all_calls]

        #     # Print the result
        #     f.write(f"From entry_point the functions reached are {all_calls_formated}\n")
        # else:
        #     f.write("From entry_point no functions reached\n")
        problem_in_contract = []
        if contract.name not in contracts_scanned:
            contracts_scanned.append(contract.name)
        else:
            continue
        
        if contract.name not in contracts_in_sol_file:
            continue
        print(f'{contract.name}:')
        # if contract.name != 'IdentityStaking':
        #     continue
        for value in contract.state_variables:
            if value.is_constant:
                problem_in_contract.append('2.5')
        # if get_public_constant_variables(sol_file,contract.name):
        #     problem_in_contract.append('2.5')
        
        state_variable_written_only_constructor = []
        state_variable_has = False
        for v in contract.state_variables:
            state_variable_has = True
            break
        count = 0
    
        for function in contract.functions:
            # continue
            # if contract.name != 'PrelaunchPoints':
            #     continue
            # if count == 0:
            #     count = 1
            #     continue
            # if count != 1:
            #     count += 1
            #     continue
            print(f'{function.name}:')
            function_begin_index = 0
            function_end_index = 0
            count = 0
            is_get_lines = False
            first_function = True
            for index,line in enumerate(sol_content):
                # if not function.is_constructor and line.strip().startswith('function '+function.name+'(') and first_function:
                #     first_function = False
                #     continue
                if not function.is_constructor and line.strip().startswith('function '+function.name+'(') :
                    function_begin_index = index
                elif function.is_constructor and line.strip().startswith('constructor('):
                    function_begin_index = index
                if function_begin_index != 0:
                    if '{' in line or '}' in line:
                        is_get_lines = True
                    for char in line:
                        if char == '{':
                            count += 1
                        elif char == '}':
                            count -= 1
                    # print(count)
                if count == 0 and is_get_lines:
                    function_end_index = index + 1
                    break
            # for index,line in enumerate(sol_content):
            #     if not function.is_constructor and line.startswith('    function '+function.name+'('):
            #         function_begin_index = index
            #     elif function.is_constructor and line.startswith('    constructor('):
            #         function_begin_index = index
            #     if function_begin_index != 0 and line.startswith('    }'):
            #         function_end_index = index + 1
            #         break
            if function_begin_index == 0 :
                continue
            # print(function_begin_index)
            # print(function_end_index)
            function_content = ''.join(sol_content[function_begin_index:function_end_index])
            problem_in_function = ['2.2','2.4','4.1','2.11']
            if function_modifier_check(sol_file,contract.name,function,directory):
                problem_in_function.append('1.1')
            read_vars = ', '.join([v.name for v in function.state_variables_read])
            written_vars = ', '.join([v.name for v in function.state_variables_written])
            # print(read_vars)
            result_params = re.split(r'[()]', function_content)
            if len(result_params) > 1:
                result_param = result_params[1]
            memory_param = []
            variable_not_get_muted = []
            for part in result_param.split(','):
                if 'memory' in part:
                    memory_param.append(part.strip().split(' ')[-1])
            # print(memory_param)
            for parameter in function.parameters:
                if parameter.name in memory_param:
                    variable_not_get_muted.append(parameter)
            # print(variable_not_get_muted)
            # variable_not_get_muted = function.parameters

            is_variable_used_once = False
            is_variable_no_used = False
        
            num_of_if_statement = 0
            variable_used_map = {}

            # print(function.parameters)
            is_state_variable_rereading = False
            state_variable_map = {item: 0 for item in function.state_variables_read}

            if function.is_constructor:
                state_variable_written_only_constructor = function.state_variables_written
            else:
                for v in state_variable_written_only_constructor:
                    if v in function.state_variables_written:
                        state_variable_written_only_constructor.remove(v)
            
            for node in function.nodes:
                # print(node.type)
                # print(str(node.expression))
                node_read_state_vars = ', '.join([v.name for v in node.state_variables_read])
                node_written_state_vars = ', '.join([v.name for v in node.state_variables_written])
                # print(node_read_state_vars)
                # print(node_written_state_vars)
            
                if node.variables_read is not None:
                    node_read_vars = ', '.join([v.name for v in node.variables_read if v is not None and hasattr(v, 'name')])
                else:
                    node_read_vars = ''
                node_written_vars = ', '.join([v.name for v in node.variables_written])
                #deal with loop situation
                for v in node.state_variables_read:
                    if v in state_variable_map:
                        state_variable_map[v]+=1

                for v in node.state_variables_written:
                    if v in state_variable_map:
                        state_variable_map[v]+=1

                for v in variable_not_get_muted:
                    if v in node.variables_written:
                        variable_not_get_muted.remove(v)

                if node.variable_declaration != None:
                    variable_used_map[str(node.variable_declaration)] = 0
                # print(node.variable_declaration)
                for v in node.local_variables_read:
                    if v.name in variable_used_map:
                        variable_used_map[v.name] += 1

                #3.7.2
                if node.variable_declaration != None:
                    if node.expression != None and str(node.expression).startswith('bool'):
                        print(f'there may be a problem : Using bools for storage incurs overhead in {function.name}')
                        problem_in_function.append('3.7')
                # print(str(node.type))
                if str(node.type) == 'NodeType.STARTLOOP':
                    problem_in_loop = loop_condition_analysis(sol_file,contract.name,function,directory)
                    # print(problem_in_loop)
                    if problem_in_loop != None:
                        problem_in_function += problem_in_loop
                    
                elif node.expression != None:


                    #2.10
                    if node.contains_require_or_assert() or str(node.expression).startswith('emit'):
                        print(f'there may be a problem : Move require emit ahead in {function.name}')
                        problem_in_function.append('2.10')

                    #2.1
                    if (node.contains_require_or_assert() or node.contains_if()) and '&&' in str(node.expression):
                        print(f'there may be a problem : Splitting require() statements that use && saves gas in {function.name}')
                        problem_in_function.append('2.1')

                    #2.3
                    if '++' in str(node.expression) or '--' in str(node.expression) or '+=' in str(node.expression) or '-=' in str(node.expression):
                        print(f'there may be a problem : ++i costs less gas compared to i++ or i += 1 (same for --i vs i-- or i -= 1) in function {function.name}')
                        problem_in_function.append('2.3')

                    #1.2
                    if str(node.expression).startswith('revert(') or str(node.expression).startswith('require('):
                        print(f'there may be a problem : use custom errors instead of revert strings to save gas in {function.name}')
                        problem_in_function.append('1.2')

                    #2.8
                    if len(node.state_variables_written) == 1 and node.state_variables_written[0] in node.state_variables_read and '+=' in str(node.expression):
                        print(f'there may be a problem : a = a + b is more gas effective than a += b for state variables in {function.name}')
                        problem_in_function.append('2.8')

                    #5.1
                    if '>0' in str(node.expression) or '> 0' in str(node.expression):
                        if int(version.split('.')[1]) < 8:
                            print(f'there may be a problem : For solidty 0.8.12 or below, use != 0 instead of > 0 for unsigned integer comparison in {function.name}')
                            problem_in_function.append('5.1')
                        elif int(version.split('.')[1]) == 8 and int(version.split('.')[2]) <= 12:
                            print(f'there may be a problem : For solidty 0.8.12 or below, use != 0 instead of > 0 for unsigned integer comparison in {function.name}')
                            problem_in_function.append('5.1')


                    #3.6
                    if len(node.state_variables_written) != 0 and not function.is_constructor:
                        print(f'there may be a problem : check before updating state variable with same value in {function.name}')
                        problem_in_function.append('3.6')
                    
                    #2.6
                    expression_parts = str(node.expression).split(' ')
                    for index,part in enumerate(expression_parts):
                        if part == '*' or part == '/':
                            if is_int(expression_parts[index+1]) and is_two_mi(int(expression_parts[index+1])):
                                print(f'there may be a problem : Use shift right/left instead of division/multiplication if possible in {function.name}')
                                problem_in_function.append('2.6')

                    if node.contains_if() or node.contains_require_or_assert():
                        print(variable_used_map)
                        num_of_if_statement += 1
                        if '||' in str(node.expression):
                            print(f'there may be a problem : Comparison statement order adjustment in {function.name}')
                            problem_in_function.append('2.7')
                        for v in variable_used_map:
                            if variable_used_map[v] == 0:
                                print(f'there may be a problem : Comparison statement order adjustment in {function.name}')
                                problem_in_function.append('2.7')



            #3.1
            if len(variable_not_get_muted) != 0:
                print(f'there may be a problem : Use calldata instead of memory for function arguments that do not get mutated in {function.name}')
                problem_in_function.append('3.1')
            
            #2.7
            if num_of_if_statement >= 2:
                print(f'there may be a problem : Comparison statement order adjustment in {function.name}')
                problem_in_function.append('2.7')

            variable_used_once = []
            variable_no_use = []

            for v in variable_used_map:
                if variable_used_map[v] == 1:
                    variable_used_once.append(v)
                    is_variable_used_once = True
                if variable_used_map[v] == 0:
                    variable_no_use.append(v)
                    is_variable_no_used ==True
                

            for v in state_variable_map:
                if state_variable_map[v] > 1:
                    is_state_variable_rereading = True

            #3.5
            if is_variable_used_once:
                print(f'there may be a problem : Do not declare local variables used only once in {function.name}')
                problem_in_function.append('3.5')

            #1.3.1
            if is_variable_no_used:
                print(f'there may be a problem : Avoid declaring unused variables or unused internal function in {function.name}')
                problem_in_function.append('1.3')

            #3.2
            if is_state_variable_rereading:
                print(f'there may be a problem : state variables should be cached in stack variables rather than re-reading them from storage in {function.name}')
                problem_in_function.append('3.2')

            problem_in_function = list(set(problem_in_function))
            print(problem_in_function)
            content = 'solidity version :'+ str(version)+'\n' 
            if '3.5' in problem_in_function:
                variable_used_once_str = ', '.join([v for v in variable_used_once])
                content+='variable used once:'+variable_used_once_str+'\n'
            if '1.3' in problem_in_function:
                variable_no_use_str = ', '.join([v for v in variable_no_use])
                content+='variable no use:'+variable_no_use_str+'\n'

            content+= 'function state variables read:' + read_vars +'\n' \
                + 'function state variables written:' + written_vars +'\n' + function_content
            function_result_file = result_path+contract.name+'-'+function.name+'.txt'
            if os.path.exists(function_result_file):
                continue
            gpt_check_function(content,problem_in_function,function_result_file)

        # continue
        #3.3
        if len(state_variable_written_only_constructor) != 0:
            print(f'there may be a problem : State variables only set in the constructor should be declared immutable in {contract.name}')
            problem_in_contract.append('3.3')
        
        #3.4
        if state_variable_has:
            print(f'there may be a problem : Pack the variables into fewer storage slots by re-ordering the variables or reducing their sizes in {contract.name}')
            problem_in_contract.append('3.4')

        #3.7.1
        if state_variable_has:
            print(f'there may be a problem : Using bools for storage incurs overhead in {contract.name}')
            problem_in_contract.append('3.7')
        
        problem_in_contract = list(set(problem_in_contract))
        print(problem_in_contract)
        contract_begin_index = 0
        contract_end_index = 0
        is_comment = False
        contract_state_variable_indexs = []
        for index,line in enumerate(sol_content):
            if line.startswith('contract '+contract.name) or line.startswith('abstract contarct '+contract.name) or line.startswith('library '+contract.name) or line.startswith('interface '+contract.name):
                contract_begin_index = index
            if contract_begin_index != 0:
                line_strip = line.strip(' \n')
                if is_comment and line_strip.endswith('*/'):
                    # print(index)
                    is_comment = False
                    continue
                if is_comment:
                    # print(index)
                    continue
                if line_strip == '' or line_strip.startswith('//') or line_strip.startswith('error') or line_strip.startswith('event'):
                    continue
                if line_strip.startswith('/*'):
                    is_comment = True
                    continue
                
                if line_strip.startswith('function') or line.startswith('}'):
                    contract_end_index = index
                    break
                # print(index)
                contract_state_variable_indexs.append(index)
        state_variable_written_only_constructor_name = []
        for v in state_variable_written_only_constructor:
            state_variable_written_only_constructor_name.append(v.name)
        contract_content = ''.join([sol_content[i] for i in contract_state_variable_indexs])
        content = 'solidity version :'+ str(version)+'\n'+ 'variable written only construct:' + str(state_variable_written_only_constructor_name)+'\n' + contract_content
        contract_result_file = result_path+contract.name+'.txt'
        if os.path.exists(contract_result_file):
            continue
        if len(problem_in_contract) == 0:
            print(f"no optimization about the state variable of {contract.name}")
        else:
            gpt_check_contract(content,problem_in_contract,contract_result_file)
    # if sol_file == '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-05-loop/src/PrelaunchPoints.sol':
    #     break
      

                    
                    
                    
                
                    
            

            # print(f'\tRead: {read_vars}')
            # print(f'\tWritten: {written_vars}')

# import os
# # 设置目标文件夹路径
# directory_path = '/nasdata/ruanyijie/gas_optimization/solidity_files/2023-11-panoptic/'

# from slither.slither import Slither  
# result = Slither(directory_path)
# for contract in result.contracts:
#     print(contract.name)
# print(result)