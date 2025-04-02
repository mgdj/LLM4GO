import os
import pandas as pd

def find_and_read_csv_files(directory):
    # 遍历文件夹下的所有文件及子文件夹
    true_count=0
    false_count=0
    for filename in os.listdir(directory):
    # 检查文件是否是 .txt 文件
        if filename.endswith('.txt'):
            file_path = os.path.join(directory, filename)
            try:
                with open(file_path, 'r', encoding='utf-8') as file:
                    content = file.read()
                    # 检查文件内容是否包含 "no need"
                    if "no need" in content:
                        true_count += 1
                    else:
                        false_count += 1
            except Exception as e:
                print(f"无法读取文件 {filename}: {e}")
    print(true_count)
    print(false_count)
# 设置你要遍历的文件夹路径
directory_all = "/nasdata/ruanyijie/gas_optimization/src/fp_result_gpt-static/"
entries = os.listdir(directory_all)
subdirectories = [os.path.join(directory_all, entry) for entry in entries if os.path.isdir(os.path.join(directory_all, entry))]
print(subdirectories)
for directory in subdirectories :
    print(directory)
    find_and_read_csv_files(directory)