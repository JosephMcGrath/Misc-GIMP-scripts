# -*- coding: utf-8 -*-

import os
from typing import List


def list_files(dir_in: str) -> str:
    """Recursively lists all the files in a directory."""
    return [
        os.path.join(dp, f) for dp, _, filenames in os.walk(dir_in) for f in filenames
    ]


def filter_extensions(file_list: List[str], extensions: List[str]) -> List[str]:
    """Filters a list of files based on their extensions."""
    if type(extensions) == str:
        extensions = [extensions]
    extensions = set([x.lower() for x in extensions])
    return [x for x in file_list if os.path.splitext(x)[1].lower() in extensions]


def filtered_file_list(dir_in: str, extensions: List[str]) -> List[str]:
    """Returns files in the directory with matching extensions."""
    return filter_extensions(list_files(dir_in), extensions)
