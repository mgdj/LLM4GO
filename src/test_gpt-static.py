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
        base_url='https://api.openai-proxy.org/v1',
        api_key='sk-cEOsqGI9gAOrxgqQ6D1B9U3nvZrpzsy98m03RDfrNf9XOYwP',
    )
    chat_completion = client.chat.completions.create(
        model="chatgpt-4o-latest",
        messages=[
            {"role": "system", "content": "You are an expert in Solidity programming and gas optimization, capable of providing detailed recommendations and optimized code snippets.There are serveral kinds of optimizations may appear in the code.\n"+hint_message},
            {"role": "user", "content": "Can you help me optimize the following Solidity code to save more gas? The code is mainly the state variables in a contract. You just need to consider these hint meaasge items. For each item, can you give your reasoning process and reasoning results at each step? At the end of the answer only need to output 'need' or 'no need' as the result, do not need to output suggestions and optimized code.Ensure that the code modifications are made to the existing code without importing additional libraries and adding unnecessary functions.\n"+content}
        ]
    )
    with open(result_path, 'w') as file:
        # 将字符串写入文件
        file.write(chat_completion.choices[0].message.content)

def gpt_check_function(content,problems,result_path):
    hint_message = '    '
    for index,problem in enumerate(problems):
        hint_message+= str(index+1) +'.' + Prompt_MAP_CONSTANT[problem]
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
            {"role": "user", "content": "Can you help me optimize the following Solidity code to save more gas? The code is a function in contract. You just need to concern the items i given you obove. For each item, can you give your reasoning process and reasoning results at each step? If you're not sure you need to optimize, don't make changes. At the end of the answer only need to output 'need' or 'no need' as the result, do not need to output suggestions and optimized code. You should check items obove carefully. Ensure that the code modifications are made to the existing code without importing additional libraries and adding more functions.\n"+content}
        ]
    )
    with open(result_path, 'w') as file:
        # 将字符串写入文件
        file.write(chat_completion.choices[0].message.content)

    
# 设置目标文件夹路径
directory = '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-03-revert-lend/'
directory_path = directory + 'src/'
result_path = '/nasdata/ruanyijie/gas_optimization/src/fp_result_gpt-static/revertlend/'
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
data_file = '/nasdata/ruanyijie/gas_optimization/dataset_new/revertlend/'
for sol_file in sol_files:
    # if sol_file == '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-01-curves/contracts/Curves.sol':
    #     continue   
    problem_to_check = []
    for index,p in df.iterrows():
        if p['file'].split('#')[0] in sol_file:
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

            # print(function.parameters)
            
            for p in problem_to_check_fp:
                problems = p[1].split(' ')
                p_list = []
                for problem in problems:
                    p_list.append(problem)
                with open(data_file+p[0]+'/optimization.sol','r') as f:
                    function_content = f.read()
                content = function_content
                function_result_file = result_path+p[0]+'_approach.txt'
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
        for p in contract_to_check_fp:
            problems = p[1].split(' ')
            p_list = []
            for problem in problems:
                p_list.append(problem)
            with open(data_file+p[0]+'/optimization.sol','r') as f:
                contract_content = f.read()
            content = contract_content
            contract_result_file = result_path+p[0]+'.txt'
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