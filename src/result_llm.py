import os
import pandas as pd

def find_and_read_csv_files(directory):
    # 遍历文件夹下的所有文件及子文件夹
    for root, dirs, files in os.walk(directory):
        for file in files:
            # 检查文件是否是 .csv 文件
            if file.endswith(".csv"):
                file_path = os.path.join(root, file)
                print(file_path)
                
                df = pd.read_csv(file_path)
                df['ds_result'] = df['ds_result'].astype(str)
                ds_results = df['ds_result'].str.split()
                df['llama_result'] = df['llama_result'].astype(str)
                llama_results = df['llama_result'].str.split()
                df['qwen_result'] = df['qwen_result'].astype(str)
                qwen_results = df['qwen_result'].str.split()

                # 初始化计数器
                true_count = 0
                false_count = 0

                # 遍历分割后的结果，统计true和false的数量
                for result in ds_results:
                    true_count += sum([1 for item in result if 'true' in item.lower()])
                    false_count += sum([1 for item in result if 'false' in item.lower()])

                # 输出结果
                print(f"ds true count: {true_count}")
                print(f"ds false count: {false_count}")

                # 处理 repair_results
                true_count = 0
                false_count = 0
                for result in llama_results:
                    true_count += sum([1 for item in result if 'true' in item.lower()])
                    false_count += sum([1 for item in result if 'false' in item.lower()])

                print(f"llama True count: {true_count}")
                print(f"llama False count: {false_count}")

                true_count = 0
                false_count = 0
                for result in qwen_results:
                    true_count += sum([1 for item in result if 'true' in item.lower()])
                    false_count += sum([1 for item in result if 'false' in item.lower()])

                print(f"qwen True count: {true_count}")
                print(f"qwen False count: {false_count}")

# 设置你要遍历的文件夹路径
directory = "/nasdata/ruanyijie/gas_optimization/dataset_new/"
find_and_read_csv_files(directory)