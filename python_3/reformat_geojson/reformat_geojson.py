# -*- coding: utf-8 -*-

"""
A short script to clean & re-format GeoJSON files to:

    * Remove un-needed decimal places.
    * Make the outputs more amenable to version control on minor changes.
    
"""

import json
import collections
import os
import re

def round_coordinates(to_round : list, to_places : int = 1) -> list:
    """Returns the coordinate part of a GeoJSON geature with rounded values."""
    if type(to_round) == list:
        return [round_coordinates(x, to_places) for x in to_round]
    elif type(to_round) == float:
        return round(to_round, to_places)
    elif type(to_round) == int:
        return to_round
    else:
        print(f'Error with: ', to_round)

def clean_feature(feature_in : dict, to_places : int = 1) -> dict:
    """Carries out all the cleanup on a GeoJSON feature."""
    feature_in['geometry']['coordinates'] = \
        round_coordinates(feature_in['geometry']['coordinates'],
                          to_places
                          )
    return feature_in

def reindent_geojson(geojson : str) -> str:
    """Adjusts the default indentation of the GeoJSON to be more readable."""
    
    # Collapse coordinate pairs into a single line each.
    geojson = re.sub(r'\[\s+(-*\d+\.\d*),\s*(-*\d+\.\d*)\s*\]',
                     r'[ \1, \2 ]',
                     geojson
                     )
    
    return geojson

def clean_geojson(file_path : str, key = 'fid') -> str:
    """Cleans up a single GeoJSON file in place."""
    with open(file_path, 'r') as f:
        raw = json.load(f, object_pairs_hook = collections.OrderedDict)
    
    raw['features'] = [clean_feature(x) for x in raw['features']]
    
    raw['features'] = sorted(raw['features'],
                             key = lambda x: x['properties'].get(key)
                             )
    
    output =  json.dumps(obj = raw,
                         indent = 1
                         )
    output = reindent_geojson(output)
    
    with open(file_path, 'w') as f:
        f.writelines(output)
    
    return output

def find_json(dir_in : str) -> str:
    """Locates all the GeoJSON files in a directory."""
    return [os.path.join(dir_in, x)
            for x in os.listdir(dir_in)
            if os.path.splitext(x)[-1] == '.geojson'
            ]

def clean_all_json(dir_in : str) -> None:
    """Cleans up all the GeoJSON files in a directory."""
    for file in find_json(dir_in):
        clean_geojson(file)


#==============================================================================
if __name__ == "__main__":
    dir_in = os.path.join(os.path.split(os.getcwd())[0],
                          'maps'
                          )
    
    output = clean_all_json(dir_in)
