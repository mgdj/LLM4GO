import pandas as pd

# 读取CSV文件
df_c4 = pd.read_csv('./c4.csv')
df_4nalyser = pd.read_csv('./4nalyser.csv')

# 对description列进行处理：去掉括号及之后的部分，然后去掉首尾空格并转换为小写
# df_c4['type'] = df_c4['type'].apply(lambda x: x.split('[')[0].strip().lower())

# # 对description列中的条目进行计数
# item_counts_c4 = df_c4['type'].value_counts()

# # 将结果写入到result.txt文件
# with open('result_c4.txt', 'w') as f:
#     for item, count in item_counts_c4.items():
#         f.write(f'{item}: {count}\n')

# df_4nalyser['type'] = df_4nalyser['type'].apply(lambda x: x.split('[')[0].strip().lower())

# # 对description列中的条目进行计数
# item_counts_4nalyser = df_4nalyser['type','status'].value_counts()

# # 将结果写入到result.txt文件
# with open('result_4nalyser.txt', 'w') as f:
#     for item, count in item_counts_4nalyser.items():
#         f.write(f'{item}: {count}\n')


df_fp = df_4nalyser[df_4nalyser['status'] == 'fp']

df_fp['type'] = df_fp['type'].apply(lambda x: x.split('[')[0].strip().lower())

# 对description列中的条目进行计数
item_counts_4nalyser = df_fp['type'].value_counts()

# 将结果写入到result.txt文件
with open('result_4nalyser_fp.txt', 'w') as f:
    for item, count in item_counts_4nalyser.items():
        f.write(f'{item}: {count}\n')