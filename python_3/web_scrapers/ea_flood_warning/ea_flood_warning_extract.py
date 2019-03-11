# -*- coding: utf-8 -*-

import zipfile
import pandas as pd
import os


def pull_gauges(df, measure_list, output):
    """
    Appends the data for a particular set of measures from a data frame to a
    dictionary of dataframes.
    """
    for gauge in measure_list:
        if gauge in output:
            output[gauge] = output[gauge].append(
                df[df["measure"] == gauge], ignore_index=True
            )
        else:
            blank = pd.DataFrame(columns=["dateTime", "measure", "value"])
            output[gauge] = blank.append(df[df["measure"] == gauge], ignore_index=True)

    return output


def pull_file(src_list, measure_list):
    """
    Extracts the data for a set of measures from a list of zip files to a
    dictionary of dataframes.
    """
    output = {}
    for src_file in sorted(src_list):
        with zipfile.ZipFile(src_file) as source:
            for file_name in sorted(source.filelist, key=lambda x: x.filename):
                print(file_name)
                df = pd.read_csv(
                    source.open(file_name.filename), parse_dates=["dateTime"]
                )
                output = pull_gauges(df, measure_list, output)
    return output


def write_data(data, dst_dir):
    """Writes a set of data """
    for measure in data:
        path_out = os.path.join(dst_dir, os.path.split(measure)[-1] + ".csv")
        data[measure].sort_values(by="dateTime").to_csv(path_out, index=False)


# write_data(pull_file(zip_list, measure_list), dst_dir)
