import os
import pandas as pd

# Specify the directory containing the .csv files
directory = '/nasdata/ruanyijie/gas_optimization/data_collect/'

# Lists to store DataFrames for each type
code4rena_dfs = []
automated_dfs = []

# Iterate through all files in the directory
for filename in os.listdir(directory):
    file_path = os.path.join(directory, filename)

    # Check if it's a .csv file and process based on its filename suffix
    if filename.endswith('.csv'):
        if filename.endswith('code4rena.csv'):
            print(filename)
            # Read the 'type' column only and add to the list
            df = pd.read_csv(file_path, usecols=['type'])
            code4rena_dfs.append(df)
        elif filename.endswith('automated.csv'):
            # Read the 'type' and 'status' columns and add to the list
            print(filename)
            df = pd.read_csv(file_path, usecols=['type', 'status'])
            automated_dfs.append(df)

# Concatenate all DataFrames for each type and output to new files
if code4rena_dfs:
    pd.concat(code4rena_dfs, ignore_index=True).to_csv('c4.csv', index=False)

if automated_dfs:
    pd.concat(automated_dfs, ignore_index=True).to_csv('4nalyser.csv', index=False)