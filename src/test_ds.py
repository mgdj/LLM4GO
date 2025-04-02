import os
import re
import subprocess
import pandas as pd
from slither.slither import Slither  
from slither.slithir.convert import convert_expression
from openai import OpenAI
import util.dot_solve
import util.function_modifier
import util.get_variable
import util.prompt
from util.dot_solve import get_message
from util.function_modifier import function_modifier_check
from util.get_variable import get_public_constant_variables
from util.prompt import Prompt_MAP_CONSTANT

hint_mesage_all = '''Here are common situations in gas optimization:
functions guaranteed to revert when called by normal users can be marked payable
use custom errors instead of revert strings to save gas
Avoid declaring unused variables or unused internal function
Splitting require() statements that use && saves gas
Using unchecked blocks to save gas
++i costs less gas compared to i++ or i += 1 (same for --i vs i-- or i -= 1)
Unnecessary casting or expression
Using private rather than public for constants saves gas
Use shift right/left instead of division/multiplication if possible
Comparison statement order adjustment
a = a + b is more gas effective than a += b for state variables
Cache array length outside of loop
Move require emit ahead
Repetitive code optimization
Use calldata instead of memory for function arguments that do not get mutated
state variables should be cached in stack variables rather than re-reading them from storage
State variables only set in the constructor should be declared immutable & Use immutables variables directly instead of caching them in stack
Pack the variables into fewer storage slots by re-ordering the variables or reducing their sizes
Do not declare local variables used only once
check before updating state variable with same value
Using bools for storage incurs overhead
Creating memory variable or emitting should be outside of loop
Cache state variables outside of loop
use inline assembly for arithmetic operations including address(0),uint zero,msg.sender,emitted events with two data arguments
for solidity 0.8.12 below, Use != 0 instead of > 0 for unsigned integer comparison
'''
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
    
def gpt_check_contract(content,problems,result_path):
    hint_message = '    '
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
            model="deepseek-r1",
            messages=[
                {"role": "system", "content": "You are an expert in Solidity programming and gas optimization, capable of providing detailed recommendations and optimized code snippets.There are serveral kinds of optimizations may appear in the code.\n"+hint_message},
                {"role": "user", "content": "Can you help me optimize the following Solidity code to save more gas? The code is mainly the state variables in a contract. You just need to consider these hint meaasge items. For each item, can you give your reasoning process and reasoning results at each step? At the end of the answer only need to output 'need' or 'no need' as the result, do not need to output suggestions and optimized code.\n"+content}
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
        file.write(chat_completion.choices[0].message.reasoning_content+'\n'+ chat_completion.choices[0].message.content)

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
    # client = OpenAI(
    #     api_key='sk-9mmWEaOYpzeNjEqmI9DZpv4OCBN5KaijlRMCsCv5JmfbNRw7',
    #     base_url='https://api.lkeap.cloud.tencent.com/v1',
    #     timeout=120
    # )
    try:
        chat_completion = client.chat.completions.create(
            model="deepseek-r1",
            messages=[
                {"role": "system", "content": "You are an expert in Solidity programming and gas optimization, capable of providing detailed recommendations and optimized code snippets.There are serveral kinds of optimizations may appear in the code.\n"+hint_message},
                {"role": "user", "content": "Can you help me optimize the following Solidity code to save more gas? The code is a function in contract. You just need to concern the items i given you obove. For each item, can you give your reasoning process and reasoning results at each step? If you're not sure you need to optimize, don't make changes. At the end of the answer only need to output 'need' or 'no need' as the result, do not need to output suggestions and optimized code. You should check items obove carefully.\n"+content}
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
        file.write(chat_completion.choices[0].message.reasoning_content+'\n'+ chat_completion.choices[0].message.content)

    
# 设置目标文件夹路径
directory = '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-03-revert-lend/'
directory_path = directory + 'src/'
result_path = '/nasdata/ruanyijie/gas_optimization/src/fp_result_ds/revertlend/'
if not os.path.exists(result_path):
    os.makedirs(result_path)
# 获取所有以.sol结尾的文件的绝对路径
df = pd.read_csv('/nasdata/ruanyijie/gas_optimization/dataset_new/revertlend/revertlend_result.csv')
# print(df)
sol_files = []
for root, dirs, files in os.walk(directory_path):
    for file in files:
        if file.endswith('.sol'):
            sol_files.append(os.path.join(root, file))
# 遍历这些路径
slither = Slither(directory)
command = 'slither '+directory+' --print function-summary'
output_file = './function-summary.txt'
execute_command_and_save(command,output_file)
data_file = '/nasdata/ruanyijie/gas_optimization/dataset_new/revertlend/'
for sol_file in sol_files:
    # if sol_file == '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-01-curves/contracts/Curves.sol':
    #     continue   
    problem_to_check = []
    for index,p in df.iterrows():
        if p['file'].split('#')[0] in sol_file:
            print(1)
            tmp_num = int(p['index'])
            file_index = f"{tmp_num:03}"
            # file_index = str(p['index'])
            with open(data_file+file_index+'/optimization.sol','r') as f:
                content = f.read()
                # print(content)
                contents = content.strip().split(r' ')
                if content.strip().startswith('constructor'):
                    problem_to_check.append([file_index,contents[0].split('(')[0],str(p['type']),'1'])
                if content.strip().startswith('function'):
                    problem_to_check.append([file_index,contents[1].split('(')[0],str(p['type']),'1'])
                if content.strip().startswith('contract') or content.startswith('library') or content.startswith('interface'):
                    problem_to_check.append([file_index,contents[1],str(p['type']),'2'])
                if content.strip().startswith('abstract contract'):
                    problem_to_check.append([file_index,contents[2],str(p['type']),'2'])
    # print(sol_file)
    print(problem_to_check)
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
    print(contracts_in_sol_file)
    # print(version)
    # print(contracts_in_sol_file)
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
        # if contract.name != 'PrelaunchPoints':
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
            need_to_check = False
            function_content = ''
            problem_to_check_fp = []
            index_num = 0
            for p in problem_to_check:
                if p[1] == function.name:
                    index_num = p[0]
                    need_to_check = True
                    problems = p[2].split(' ')
                    # for problem in problems:
                    problem_to_check_fp.append([p[0],p[2]])
                    # with open(data_file+p[0]+'/optimization.sol','r') as f:
                    #     function_content = f.read()
            if not need_to_check:
                continue
            # continue
            # if contract.name != 'AiArenaHelper' or function.name != 'constructor':
            #     continue
            # if count == 0:
            #     count = 1
            #     continue
            print(f'{function.name}:')
            function_begin_index = 0
            function_end_index = 0
            count = 0
            is_get_lines = False
            # for index,line in enumerate(sol_content):
            #     if not function.is_constructor and line.strip().startswith('function '+function.name+'('):
            #         function_begin_index = index
            #     elif function.is_constructor and line.strip().startswith('constructor('):
            #         function_begin_index = index
            #     if function_begin_index != 0:
            #         if '{' in line or '}' in line:
            #             is_get_lines = True
            #         for char in line:
            #             if char == '{':
            #                 count += 1
            #             elif char == '}':
            #                 count -= 1
            #         # print(count)
            #     if count == 0 and is_get_lines:
            #         function_end_index = index + 1
            #         break
            # # for index,line in enumerate(sol_content):
            # #     if not function.is_constructor and line.startswith('    function '+function.name+'('):
            # #         function_begin_index = index
            # #     elif function.is_constructor and line.startswith('    constructor('):
            # #         function_begin_index = index
            # #     if function_begin_index != 0 and line.startswith('    }'):
            # #         function_end_index = index + 1
            # #         break
            # if function_begin_index == 0 :
            #     continue
            # # print(function_begin_index)
            # # print(function_end_index)
            # function_content = ''.join(sol_content[function_begin_index:function_end_index])
            problem_in_function = ['2.2','2.4','2.11']
            if function_modifier_check(sol_file,contract.name,function,directory):
                problem_in_function.append('1.1')
            read_vars = ', '.join([v.name for v in function.state_variables_read])
            written_vars = ', '.join([v.name for v in function.state_variables_written])
            # print(read_vars)
            variable_not_get_muted = function.parameters

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
                # print(node.expression)
                # continue
                node_read_state_vars = ', '.join([v.name for v in node.state_variables_read])
                node_written_state_vars = ', '.join([v.name for v in node.state_variables_written])
                if node.variables_read is not None:
                    node_read_vars = ', '.join([v.name for v in node.variables_read if v is not None])
                else:
                    node_read_vars = ''
                node_written_vars = ', '.join([v.name for v in node.variables_written])
                #deal with loop situation
                for v in node.state_variables_read:
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
                    if node.contains_require_or_assert() and '&&' in str(node.expression):
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
                    if len(node.state_variables_written) == 1 and node.state_variables_written[0] in node.state_variables_read :
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

                    if node.contains_if():
                        num_of_if_statement += 1

            #3.1
            if len(variable_not_get_muted) != 0 and not function.is_constructor:
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
            # if '3.5' in problem_in_function:
            #     variable_used_once_str = ', '.join([v for v in variable_used_once])
            #     content+='variable used once:'+variable_used_once_str+'\n'
            if '1.3' in problem_in_function:
                variable_no_use_str = ', '.join([v for v in variable_no_use])
                content+='variable no use:'+variable_no_use_str+'\n'
            for p in problem_to_check_fp:
                problems = p[1].split(' ')
                p_list = []
                for problem in problems:
                    p_list.append(problem)
                with open(data_file+p[0]+'/optimization.sol','r') as f:
                    function_content = f.read()
                content+= 'function state variables read:' + read_vars +'\n' \
                    + 'function state variables written:' + written_vars +'\n' + function_content
                function_result_file = result_path+p[0]+'_approach.txt'
                result_path_baseline = result_path+p[0]+'_baseline.txt'
                result_path_message = result_path+p[0]+'_message.txt'
                if os.path.exists(function_result_file):
                    continue
                gpt_check_function(content,p_list,function_result_file)

        # continue
        #3.3
        contract_to_check = False
        contract_content = ''
        contract_to_check_fp = []
        for p in problem_to_check:
            if p[1] == contract.name:
                # for problem in p[2].split(' '):
                contract_to_check_fp.append([p[0],p[2]])
                contract_to_check =True
                # with open(data_file+p[0]+'/optimization.sol','r') as f:
                #    contract_content = f.read() 
        if not contract_to_check:
            continue
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
        # for index,line in enumerate(sol_content):
        #     if line.startswith('contract '+contract.name) or line.startswith('abstract contarct '+contract.name) or line.startswith('library '+contract.name) or line.startswith('interface '+contract.name):
        #         contract_begin_index = index
        #     if contract_begin_index != 0:
        #         line_strip = line.strip(' \n')
        #         if is_comment and line_strip.endswith('*/'):
        #             # print(index)
        #             is_comment = False
        #             continue
        #         if is_comment:
        #             # print(index)
        #             continue
        #         if line_strip == '' or line_strip.startswith('//') or line_strip.startswith('error') or line_strip.startswith('event'):
        #             continue
        #         if line_strip.startswith('/*'):
        #             is_comment = True
        #             continue
                
        #         if line_strip.startswith('function') or line.startswith('}'):
        #             contract_end_index = index
        #             break
        #         # print(index)
        #         contract_state_variable_indexs.append(index)
        state_variable_written_only_constructor_name = []
        for v in state_variable_written_only_constructor:
            state_variable_written_only_constructor_name.append(v.name)
        # contract_content = ''.join([sol_content[i] for i in contract_state_variable_indexs])
        for p in contract_to_check_fp:
            problems = p[1].split(' ')
            p_list = []
            for problem in problems:
                p_list.append(problem)
            with open(data_file+p[0]+'/optimization.sol','r') as f:
                contract_content = f.read()
            content = 'solidity version :'+ str(version)+'\n'+ 'variable written only construct:' + str(state_variable_written_only_constructor_name)+'\n' + contract_content
            contract_result_file = result_path+p[0]+'.txt'
            result_path_contract_baseline = result_path+p[0]+'_baseline.txt'
            result_path_contract_message = result_path+p[0]+'_message.txt'
            if os.path.exists(contract_result_file):
                continue
            gpt_check_contract(content,p_list,contract_result_file)
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