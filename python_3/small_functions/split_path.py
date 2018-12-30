# -*- coding: utf-8 -*-

import os

def split_path(path : str) -> list:
    """Split a provided path into a list of it's parts."""
    output = []
    while os.path.split(path)[0] != path:
        path, folder = os.path.split(path)
        output.append(folder)
    
    output.append(path)
    output.reverse()
    return output
