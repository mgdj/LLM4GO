import pandas as pd

file_path = '/nasdata/ruanyijie/gas_optimization/dataset_new/spectra/spectra.csv'

df = pd.read_csv(file_path)
split_results = df['fp_result'].str.split()
gpt_results = df['fp_gpt'].str.split()
gpt_message_result = df['fp_message'].str.split()

true_count = 0
false_count = 0

# 遍历分割后的结果，统计true和false的数量
for result in split_results:
    true_count += sum([1 for item in result if 'fn' in item.lower()])
    false_count += sum([1 for item in result if 'fp' in item.lower()])

# 输出结果
print(f"True count: {true_count}")
print(f"False count: {false_count}")

# 处理 repair_results
true_count = 0
false_count = 0
for result in gpt_results:
    true_count += sum([1 for item in result if 'fn' in item.lower()])
    false_count += sum([1 for item in result if 'fp' in item.lower()])

print(f"gpt True count: {true_count}")
print(f"gpt False count: {false_count}")

# 处理 gpt_message_result
true_count = 0
false_count = 0
for result in gpt_message_result:
    true_count += sum([1 for item in result if 'fn' in item.lower()])
    false_count += sum([1 for item in result if 'fp' in item.lower()])

print(f"gpt message True count: {true_count}")
print(f"gpt message False count: {false_count}")