import networkx as nx
import os
import glob
import subprocess
#

def run_slither_command(sol_file,directory):
    # 构建命令
    command = ['slither', directory, '--print', 'cfg']
    
    # 执行命令
    result = subprocess.run(command, capture_output=True, text=True)
    
    # 打印输出结果
    if result.returncode == 0:
        print("Command print cfg executed successfully")
        # print(result.stdout)  # 输出命令的结果
    else:
        print(f"Error: {result.stderr}")

def delete_dot_files(directory):
    # 构建搜索路径，查找以 .dot 结尾的所有文件
    dot_files = glob.glob(os.path.join(directory, '*.dot'))
    
    # 遍历所有找到的文件并删除
    for file in dot_files:
        try:
            os.remove(file)
            # print(f"Deleted: {file}")
        except Exception as e:
            print(f"Error deleting {file}: {e}")

def find_files_with_prefix(directory, prefix):
    matching_files = []
    
    # 遍历目录中的所有文件
    for file_name in os.listdir(directory):
        # 构造完整文件路径
        file_path = os.path.join(directory, file_name)
        
        # 检查是否是文件（而非文件夹）并且文件名是否以指定前缀开头
        if os.path.isfile(file_path) and file_name.startswith(prefix):
            matching_files.append(os.path.join(directory,file_name))
    
    return matching_files


def read_dot_file(dot_file_path):
    graph = nx.DiGraph(nx.drawing.nx_pydot.read_dot(dot_file_path))
    return graph

def check_for_loops(graph,function_name):
    """
    检查图中是否存在循环
    """
    # 查找所有的简单环
    loops = list(nx.simple_cycles(graph)) 
    checked_nodes = []
    problem_in_loop = []

    if loops:
        # print("存在循环:")
        for loop in loops:
            for node in loop:
                node_label = graph.nodes[node].get('label', '')
                node_variable = graph.nodes[node].get('variable')
                # print(node_variable)
                # print(hasattr(node_variable,'state_variables_read'))

                #2.9
                if graph.nodes[node]['label'].split(' ')[2] == 'IF_LOOP' and node not in checked_nodes:
                    if '.' in graph.nodes[node]['label'].split('\n')[3] and 'length' in graph.nodes[node]['label'].split('\n')[3]:
                        checked_nodes.append(node)
                        print(f'there may be a problem : Cache array length outside of loop in function {function_name}')
                        problem_in_loop.append('2.9')

                #3.8.1
                if graph.nodes[node]['label'].split(' ')[2] == 'NEW' and graph.nodes[node]['label'].split(' ')[3] == 'VARIABLE' and node not in checked_nodes:
                    checked_nodes.append(node)
                    print(f'there may be a problem : Creating memory variable should be outside of loop in function {function_name}')
                    problem_in_loop.append('3.8')

                #3.8.2
                if node_variable and hasattr(node_variable, 'expression') and str(node_variable.expression).startswith('emit'):
                    checked_nodes.append(node)
                    print(f'there may be a problem : emitting should be outside of loop in function {function_name}')
                    problem_in_loop.append('3.8')

                #3.9
                if node_variable and hasattr(node_variable, 'state_variables_read') and len(node_variable.state_variables_read) != 0:
                    for v in node_variable.state_variables_read:
                        print(v.name)
                    checked_nodes.append(node)
                    print(f'there may be a problem : Cache state variables outside of loop in function {function_name}')
                    problem_in_loop.append('3.9')
                
    else:
        print("没有找到循环")
    return problem_in_loop


def get_message(file_path,contract_name,function,directory):
    # print(file_path)
    run_slither_command(file_path,directory)
    # directory = os.path.dirname(file_path)
    
    # print(directory)
    # file_name_prefix = file_name.split('.')[0]
    file_prefix = '-'+contract_name+'-'+function.name+'('
    xdot_files = find_files_with_prefix(directory,file_prefix)
    # print(xdot_files)

    graph = read_dot_file(xdot_files[0])
    for node_id, node_attr in graph.nodes(data=True):
        node_id_num = int(node_id)
        # print(node_id_num)
        if node_id_num in function.nodes:
        # print(function.nodes[node_id_num])
            node_attr['variable'] = function.nodes[node_id_num]  # 更新节点属性
    problem_in_loop = check_for_loops(graph,function.name)
    delete_dot_files(directory)
    return problem_in_loop


# test
# file_path = '/nasdata/ruanyijie/gas_optimization/solidity_files/2024-01-curves/contracts/Curves.sol'
# function = 'transferAllCurvesTokens'

# get_message(file_path,function)