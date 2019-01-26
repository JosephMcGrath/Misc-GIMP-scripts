# -*- coding: utf-8 -*-

import hashlib


def hash_file(path, algorithm, buffer_size=65536):
    with open(path, "rb") as f:
        while True:
            data = f.read(buffer_size)
            if not data:
                break
            algorithm.update(data)

    return algorithm.hexdigest()


def fetch_sha256(path, buffer_size=65536):
    return hash_file(path, hashlib.sha256(), buffer_size)
