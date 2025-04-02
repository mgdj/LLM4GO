import pandas as pd
df = pd.read_csv('/nasdata/ruanyijie/gas_optimization/dataset/panoptic_result.csv')
data_file = '/nasdata/ruanyijie/gas_optimization/dataset/'
problem_to_check = []
for index,f in df.iterrows():
    result = str(f['result'])
    results = result.split(' ')
    
    file_index = f'{f['index']:03d}'
    with open(data_file+file_index+'/optimization.sol','r') as file:
        content = file.read()
        # if(file_index == '110'):
        #     print(content.strip(' '))
        contents = content.strip().split(r' ')
        if content.strip(' ').startswith('constructor'):
            problem_to_check.append([file_index,contents[0].split('(')[0],len(results)])
        if content.strip(' ').startswith('function'):
            problem_to_check.append([file_index,contents[1].split('(')[0],len(results)])
        if content.strip(' ').startswith('contract') or content.startswith('library') or content.startswith('interface'):
            problem_to_check.append([file_index,contents[1],len(results)])
        if content.strip(' ').startswith('abstract contract'):
            problem_to_check.append([file_index,contents[2],len(results)])

for p in problem_to_check:
    print(p)