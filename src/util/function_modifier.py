import subprocess
import json
import ast

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

def function_message_extract(file_path,contract_name,directory):
    with open('./function-summary.txt','r') as f:
        result = f.read()
    # print(result)
    result_lines = result.split('\n')
    contract_start = False
    data_start =False
    function_messages = []
    count = 0
    for line in result_lines:
        # print(line)
        if line.strip() == 'Contract '+contract_name:
            contract_start = True
            continue
        elif contract_start and line.startswith('+'):
            count+=1
            if(count==2):
                data_start = True
                contract_start = False
        elif data_start and line.startswith('|'):
            # print(line)
            messages = line.split('|')
            if messages[1].strip() == '':
                continue
            filtered_list = [item.strip() for item in messages if item.strip()]
            del filtered_list[3:5]
            function_messages.append(filtered_list)
            # print(filtered_list)

        elif data_start and line.startswith('+'):
            break
    # print(function_messages)
    return function_messages

def check_for_modifier(function_messages,function):
    is_called_internal = False
    for function_message in function_messages:
        if function_message[0].split('(')[0] == function.name:
            
            list_modifiers = ast.literal_eval(function_message[2])
            # print(1)
            # print(list_modifiers)
            # print(len(list_modifiers))
            #1.1.1
            if len(list_modifiers)!=0:
                print(f'there may be a problem : functions guaranteed to revert when called by normal users can be marked payable in function {function.name}')
                return True
            if function_message[1] == 'internal':
                for function_mess in function_messages:
                    # print(function_mess[3])
                    list_intenal_calls = ast.literal_eval(function_mess[3])
                    if function.name in list_intenal_calls:
                        is_called_internal = True
                        break
                #1.3.2
                if is_called_internal == False:
                    print(f'there may be a problem : Avoid declaring unused variables or unused internal function in function {function.name}')
    
    
        # return True
    return False
        

def function_modifier_check(file_path,contract_name,function,directory):
    function_messages = function_message_extract(file_path,contract_name,directory)  
    return check_for_modifier(function_messages,function)    

#test
# file_path = '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-01-curves/contracts/Curves.sol'
# function_messages = function_message_extract(file_path,'Curves')