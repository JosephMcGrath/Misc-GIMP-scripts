# -*- coding: utf-8 -*-

import zipfile
import json


class zipped_json_loader:
    def __init__(self, file_path):
        self.file_path = file_path
        self.file_list = self.get_file_list()

    def get_file_list(self):
        return zipfile.ZipFile(self.file_path, mode="r").namelist()

    def load_single(self, name, pwd=None):
        temp = zipfile.ZipFile(self.file_path, mode="r")
        with temp.open(name, mode="r", pwd=pwd) as f:
            return json.load(f)

    def load_all(self):
        return {key: self.load_single(key) for key in self.file_list}
