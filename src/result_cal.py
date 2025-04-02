import pandas as pd

file_path = '/nasdata/ruanyijie/gas_optimization/dataset_new/renft/renft.csv'

df = pd.read_csv(file_path)
df['detect_result'] = df['detect_result'].astype(str)
split_results = df['detect_result'].str.split()
print(split_results)
repair_results = df['repair_result'].str.split()
df['gpt_result'] = df['gpt_result'].astype(str)
gpt_results = df['gpt_result'].str.split()
df['gpt_message_result'] = df['gpt_message_result'].astype(str)
gpt_message_result = df['gpt_message_result'].str.split()

# 初始化计数器
true_count = 0
false_count = 0

# 遍历分割后的结果，统计true和false的数量
for result in split_results:
    true_count += sum([1 for item in result if 'true' in item.lower()])
    false_count += sum([1 for item in result if 'false' in item.lower()])

# 输出结果
print(f"True count: {true_count}")
print(f"False count: {false_count}")

# 处理 repair_results
true_count = 0
false_count = 0
for result in repair_results:
    true_count += sum([1 for item in result if 'true' in item.lower()])
    false_count += sum([1 for item in result if 'false' in item.lower()])

print(f"repair True count: {true_count}")
print(f"repair False count: {false_count}")

# 处理 gpt_results
true_count = 0
false_count = 0
for result in gpt_results:
    true_count += sum([1 for item in result if 'true' in item.lower()])
    false_count += sum([1 for item in result if 'false' in item.lower()])

print(f"gpt True count: {true_count}")
print(f"gpt False count: {false_count}")

# 处理 gpt_message_result
true_count = 0
false_count = 0
for result in gpt_message_result:
    true_count += sum([1 for item in result if 'true' in item.lower()])
    false_count += sum([1 for item in result if 'false' in item.lower()])

print(f"gpt message True count: {true_count}")
print(f"gpt message False count: {false_count}")