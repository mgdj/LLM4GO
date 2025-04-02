import os
import json
import pandas as pd
import requests as rq
# from etherscan.contracts import Contract

# Headers for the request
send_headers = {"User-Agent": "Mozilla/5.0", "Accept": "application/json"}


def download_contract_source(root, api_sc_url, retries=3):
    # apis = [
    #     (
    #         "Etherscan",
    #         f"https://api.etherscan.io/api?module=contract&action=getsourcecode&address={contract_address}&apikey=PFB7MFCWKRFZXSTAAG1MS69A4REDJMAVED",
    #     ),
    #     (
    #         "BscScan",
    #         f"https://api.bscscan.com/api?module=contract&action=getsourcecode&address={contract_address}&apikey=9ZQJN9E9Y8F1E7W4TXW4N7VPQBX7ZKA7CP",
    #     ),
    #     (
    #         "PolygonScan",
    #         f"https://api.polygonscan.com/api?module=contract&action=getsourcecode&address={contract_address}&apikey=A35H9IN3YU9EX7S3NSGVRAJPE9N7XEF2RP",
    #     ),
    #     (
    #         "Cronoscan",
    #         f"https://api.cronoscan.com/api?module=contract&action=getsourcecode&address={contract_address}&apikey=FD9TPSBQUVJHSVA3F4EKMKNMB3NXSWMXJF",
    #     ),
    #     (
    #         "Snowtrace",
    #         f"https://api.snowtrace.io/api?module=contract&action=getsourcecode&address={contract_address}&apikey=XAK4BE6TQG85NCS1X26616XNK8C8JE11F3",
    #     ),
    #     (
    #         "FtmScan",
    #         f"https://api.ftmscan.com/api?module=contract&action=getsourcecode&address={contract_address}&apikey=PYCC95BNX3Q4DZPJFSIC5WHP48D1HTMNND",
    #     ),
    #     (
    #         "MoonbeamScan",
    #         f"https://api-moonbeam.moonscan.io/api?module=contract&action=getsourcecode&address={contract_address}&apikey=UNERV7KXM7F16CPFJD3TBDAA2CH7346BH7",
    #     ),
    #     (
    #         "Arbiscan",
    #         f"https://api.arbiscan.io/api?module=contract&action=getsourcecode&address={contract_address}&apikey=9JWW755IJFKHCEDJSPW7SUUMYTMR2MEQ55",
    #     ),
    #     (
    #         "OptimismScan",
    #         f"https://api-optimistic.etherscan.io/api?module=contract&action=getsourcecode&address={contract_address}&apikey=AKBZJI7HYRRWYCNAJTG46WRWDUWMM3I1F8",
    #     ),
    #     (
    #         "MoonriverScan",
    #         f"https://api-moonriver.moonscan.io/api?module=contract&action=getsourcecode&address={contract_address}&apikey=V4TV2T51QV8B3944Z9QBEAFJZC9XAR8WIH",
    #     ),
    # ]

    attempt = 0
    while attempt < retries:
        try:
            print(0)
            response = rq.get(api_sc_url, headers=send_headers)
            print(1)
            if response.status_code == 200:
                result = response.json()["result"][0]
                # print(result)
                if "SourceCode" in result and result["SourceCode"] and "ContractName" in result and result["ContractName"]:
                    # print("download sc")
                    code = result["SourceCode"]
                    contract_name = result["ContractName"]
                    file_path = os.path.join(root, f"{contract_name}.sol")
                    if not os.path.exists(file_path):
                        with open(file_path, "w", encoding="utf-8") as file:
                            file.write(code)
                        print(
                            f"Folder '{contract_name}': Successfully downloaded contract"
                        )
                    else:
                        print(
                            f"Folder '{contract_name}': Contract file already exists"
                        )
                # print("a")

        except ConnectionResetError:
            print(
                f"Connection reset error, retry {attempt + 1}/{retries}"
            )
            attempt += 1  # Increase attempt count if ConnectionResetError occurs
        except Exception as e:
            print(
                f"Error encountered, Address. Error: {e}"
            )
            break  # Break and try next API on other exceptions
    return False

# def get_data(root,address,apikey):
#     api = Contract(address=address, apikey=apikey)
#     sourcecode = api.get_sourcecode()
#     result_sc = sourcecode[0]
#     if "SourceCode" in result and result["SourceCode"] and "ContractName" in result and result["ContractName"]:
#         # print("download sc")
#         code = result["SourceCode"]
#         contract_name = result["ContractName"]
#         file_path = os.path.join(root, f"{contract_name}.sol")
#         if not os.path.exists(file_path):
#         with open(file_path, "w", encoding="utf-8") as file:
#             file.write(code)
#             print(
#                 f"Folder '{contract_name}': Successfully downloaded contract"
#             )
#         else:
#             print(
#                 f"Folder '{contract_name}': Contract file already exists"
#             )
#     if "ABI" in result and result["ABI"] and "ContractName" in result and result["ContractName"]:
#         # print("download sc")
#         abi_code = result["ABI"]
#         abi_json = json.loads(abi_code)
#         contract_name = result["ContractName"]
#         file_path = os.path.join(root, f"{contract_name}.json")
#         if not os.path.exists(file_path):
#         with open(file_path, "w", encoding="utf-8") as file:
#             json.dump(abi_json, file)
#             print(
#                 f"Folder '{contract_name}': Successfully downloaded abi"
#             )
#         else:
#             print(
#                 f"Folder '{contract_name}': abi file already exists"
#             )
    

def process_contracts(addresses):
    # Add paths to other directories you want to process
    # Example: ['path\\to\\directory1', 'path\\to\\directory2']
    for address in addresses:
        api_sc_url = f"https://api.etherscan.io/api?module=contract&action=getsourcecode&address={address}&apikey=PFB7MFCWKRFZXSTAAG1MS69A4REDJMAVED"
        # api_txlist_url = f"https://api.etherscan.io/api?module=account&action=txlist&address={address}&startblock=0&endblock=99999999&page=1&offset=10&sort=asc&apikey=PFB7MFCWKRFZXSTAAG1MS69A4REDJMAVE"
        # apikey = "PFB7MFCWKRFZXSTAAG1MS69A4REDJMAVE"
        root = '/nasdata/ruanyijie/gas_optimization/data2_collect/data/'
        # name = name.replace(" ", "")
        if not os.path.exists(root):
            os.makedirs(root)
        # get_data(folder_path,address,apikey)
        download_contract_source(root,api_sc_url)
        # get_txlist(folder_path,api_txlist_url)
        

if __name__ == "__main__":
    # base_directory = "path\\to\\your\\base\\directory"
    # process_contracts(base_directory)
    addresses = [0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD]
    # print(len(unique_data_list))
    process_contracts(addresses)
    # 0xEC10f0f223e52F2d939C7372b62EF2F55173282F 
    # api_sc_url = f"https://api.etherscan.io/api?module=contract&action=getsourcecode&address=0xEC10f0f223e52F2d939C7372b62EF2F55173282F&apikey=PFB7MFCWKRFZXSTAAG1MS69A4REDJMAVED"
    # api_txlist_url = f"https://api.etherscan.io/api?module=account&action=txlist&address=0xEC10f0f223e52F2d939C7372b62EF2F55173282F&startblock=0&endblock=99999999&page=1&offset=10&sort=asc&apikey=PFB7MFCWKRFZXSTAAG1MS69A4REDJMAVE"
    # root = '/nasdata/ruanyijie/data_collect/etherscan'
    # name = "1"
    # if not os.path.exists(root):
    #     os.makedirs(root)
    # folder_path = os.path.join(root,name)
    # if not os.path.exists(folder_path):
    #     os.makedirs(folder_path)
    # download_contract_source(folder_path,api_sc_url)
    # address = '0xEC10f0f223e52F2d939C7372b62EF2F55173282F'
    # print(0)
    # api = Contract(address=address, api_key="PFB7MFCWKRFZXSTAAG1MS69A4REDJMAVED")
    # print(1)
    # sourcecode = api.get_sourcecode()
    # print(2)
    # # TODO: make this return something pretty
    # print(sourcecode[0]['SourceCode'])

    # get_txlist(folder_path,api_txlist_url)