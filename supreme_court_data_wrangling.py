import json
import pandas as pd
import os
import csv


def load_json_files(list_of_files):
    vals = [] #emply list

    list_of_files = [x for x in list_of_files if ".json" in x]
    for i, file in enumerate(list_of_files):
        print(i, len(list_of_files), file) #trying to keep track of the iterations
        with open(
            f"/Users/connorputnam/Documents/CS512/cases/{file}", errors="ignore" #opening the json files
        ) as f:
            d = json.load(f)
            vals.append(d)
    return vals


def json_to_csv(list_of_files):
    vals = load_json_files(list_of_files) #loading the files and saveing them

    df = pd.json_normalize(vals, errors="ignore") #creeaitng a pandas dataframe

    # df[df["decisions"].notna()]  # find the files without decisons
    df2 = df[df["decisions"].notna()]  # drop them
    list(df2.index)  # list of number to feed to vals
    val_updated = [vals[i] for i in list(df2.index)]  # feed them
###create a new dataframe with only the values desired
    df_decisions2 = pd.json_normalize(
        val_updated, record_path=["decisions", "votes"], errors="ignore"
    )
###expand the member.role column
    df_appoint = (
        pd.concat(
            {i: pd.DataFrame(x) for i, x in df_decisions2.pop("member.roles").items()}
        )
        .reset_index(level=1, drop=True)
        .join(df_decisions2, lsuffix="_left")
        .reset_index(drop=True)
    )
#convert to csv
    df_decisions2.to_csv("/Users/connorputnam/Documents/CS512/JSON_to_CSV.csv")
    return df.to_csv()



