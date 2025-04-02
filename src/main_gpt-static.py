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
from util.prompt import Prompt_MAP_CONSTANT

    
def gpt_check_contract(content,result_path):
    hint_message = "\n".join(Prompt_MAP_CONSTANT.values())
    
    print("hint message:")
    print(hint_message)
    print("content:")
    print(content)
    print('path:')
    print(result_path)
    client = OpenAI(
        base_url='https://api.openai-proxy.org/v1',
        api_key='sk-cEOsqGI9gAOrxgqQ6D1B9U3nvZrpzsy98m03RDfrNf9XOYwP',
    )
    chat_completion = client.chat.completions.create(
        model="chatgpt-4o-latest",
        messages=[
            {"role": "system", "content": "You are an expert in Solidity programming and gas optimization, capable of providing detailed recommendations and optimized code snippets.There are serveral kinds of optimizations may appear in the code.\n"+hint_message},
            {"role": "user", "content": "Can you help me optimize the following Solidity code to save more gas? The code is mainly the state variables in a contract. For each item, can you give your reasoning process and reasoning results at each step?finnaly please provide only the optimized code as the result, without recommendations or explanations.Ensure that the code modifications are made to the existing code without importing additional libraries and adding unnecessary functions.\n"+content}
        ],
        max_tokens=16384
    )
    with open(result_path, 'w') as file:
        # 将字符串写入文件
        file.write(chat_completion.choices[0].message.content)

def gpt_check_function(content,result_path):
    hint_message = "\n".join(Prompt_MAP_CONSTANT.values())
    print(hint_message)
    print(content)
    print(result_path)
    client = OpenAI(
        base_url='https://api.openai-proxy.org/v1',
        api_key='sk-cEOsqGI9gAOrxgqQ6D1B9U3nvZrpzsy98m03RDfrNf9XOYwP',
    )
    chat_completion = client.chat.completions.create(
        model="chatgpt-4o-latest",
        messages=[
            {"role": "system", "content": "You are an expert in Solidity programming and gas optimization, capable of providing detailed recommendations and optimized code snippets.There are serveral kinds of optimizations may appear in the code.\n"+hint_message},
            {"role": "user", "content": "Can you help me optimize the following Solidity code to save more gas? The code is a function in contract. For each item, can you give your reasoning process and reasoning results at each step? finnaly please provide the optimized code as the result, without recommendations or explanations. You should check items obove carefully. Ensure that the code modifications are made to the existing code without importing additional libraries and adding more functions.If you think there is nothing to optimization, just make no change.\n"+content}
        ],
        max_tokens=16384
    )
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
    sol_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.sol'):
                sol_files.append(os.path.join(root, file))
    return sol_files
# 设置目标文件夹路径
directory = '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-02-spectra/'
directory_path = directory+'src/'
result_path = '/nasdata/ruanyijie/gas_optimization/src/result_gpt-static/spectra/'

df = pd.read_csv('/nasdata/ruanyijie/gas_optimization/dataset_new/spectra/spectra.csv')
data_file = '/nasdata/ruanyijie/gas_optimization/dataset_new/spectra/'
if not os.path.exists(result_path):
    os.makedirs(result_path)
# 获取所有以.sol结尾的文件的绝对路径
# sol_files = []
# for root, dirs, files in os.walk(directory_path):
#     for file in files:
#         if file.endswith('.sol'):
#             sol_files.append(os.path.join(root, file))
sol_files = find_sol_files(directory_path)
# 遍历这些路径function
slither = Slither(directory)
for sol_file in sol_files:
    # if sol_file == '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-01-curves/contracts/Curves.sol':
    #     continue   
    problem_to_check = []
    for index,p in df.iterrows():
        if p['file'].split('#')[0] in sol_file:
            print(1)
            # tmp_num = int(p['index'])
            # file_index = f"{tmp_num:03}"
            file_index = str(p['index'])
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
        # if contract.name != 'Core':
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
            need_to_check = False
            for p in problem_to_check:
                if p[1] == function.name:
                    index_num = p[0]
                    need_to_check = True
                    problems = p[2].split(' ')
                    # for problem in problems:
                    # with open(data_file+p[0]+'/optimization.sol','r') as f:
                    #     function_content = f.read()
            if not need_to_check:
                continue
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
            

            content =  function_content
            function_result_file = result_path+contract.name+'-'+function.name+'.txt'
            if os.path.exists(function_result_file):
                continue
            gpt_check_function(content,function_result_file)

        # continue
        #3.3
        contract_to_check = False
        for p in problem_to_check:
            if p[1] == contract.name:
                # for problem in p[2].split(' '):
                contract_to_check =True
                # with open(data_file+p[0]+'/optimization.sol','r') as f:
                #    contract_content = f.read() 
        if not contract_to_check:
            continue
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
        
        contract_content = ''.join([sol_content[i] for i in contract_state_variable_indexs])
        content = contract_content
        contract_result_file = result_path+contract.name+'.txt'
        if os.path.exists(contract_result_file):
            continue
        gpt_check_contract(content,contract_result_file)
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