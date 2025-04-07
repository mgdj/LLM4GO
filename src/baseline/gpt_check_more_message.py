import os
import subprocess
import pandas as pd
import shutil
from openai import OpenAI
parent_directory = '/nasdata/ruanyijie/gas_optimization/dataset_new/aiarena/'
hint_mesage = '''Here are common situations in gas optimization:
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
i =0 
for subdir in os.listdir(parent_directory):
    subdir_path = os.path.join(parent_directory, subdir)
    if os.path.isfile(subdir_path):
        continue
    # subdir_path = '/nasdata/ruanyijie/gas_optimization/dataset/002'
    original_txt_path = os.path.join(subdir_path, 'original.sol')
    store_file = os.path.join(subdir_path, 'gpt_result_more_message.txt')
    content = ""
    if os.path.isfile(store_file):
        i+=1
        print(subdir_path)
        print("gpt checked.")
        continue
    if not os.path.exists(original_txt_path):
        continue
    if os.path.isfile(original_txt_path):
        i+=1
        print(i)
        with open(original_txt_path, 'r') as file:
            content = file.read()
    # except FileNotFoundError:
    #     print('file not found')
    #     break
    # except Exception as e:
    #     print('other')
    #     break
    # ask_question = code_content + '\n' + 'Above is the solidity code, help me upgrade it from version '+old_version+' to version '+new_version
    # print(ask_question)
    client = OpenAI(
        base_url='https://api.openai-proxy.org/v1',
        api_key='Your_Api_Key',
    )
    chat_completion = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "You are an expert in Solidity programming and gas optimization, capable of providing detailed recommendations and optimized code snippets.\n"+hint_mesage},
            {"role": "user", "content": "Can you help me optimize the following Solidity code to save more gas? Please output the optimized result only without any recommendation or explanation. Ensure that the code modifications are made to the existing code without importing additional libraries and adding more functions.\n"+content}
        ]
    )
    # print(chat_completion)
    # print(chat_completion.choices[0].message.content)
    with open(store_file, 'w') as file:
        # 将字符串写入文件
        file.write(chat_completion.choices[0].message.content)

    # 输出成功信息
    print(f"Content has been written to {store_file}")
    # break
    # print(os.getcwd)
    # break
    