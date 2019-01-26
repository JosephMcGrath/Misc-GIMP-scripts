# -*- coding: utf-8 -*-

import hashlib


def hash_object(obj, algorithm):
    """
    Calculates the hash of an object by converting it to a string.
    
    >>> hash_object('Hello', hashlib.sha256())
    '185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969'
    
    >>> hash_object('Hello', hashlib.md5())
    '8b1a9953c4611296a827abf8c47804d7'
    """
    algorithm.update(str(obj).encode("utf-8"))

    return algorithm.hexdigest()


def sha256_object(obj):
    """
    Calculates the SHA256 of an object.
    
    >>> sha256_object('Hello')
    '185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969'
    
    >>> sha256_object(1)
    '6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b'
    """
    return hash_object(obj, hashlib.sha256())


if __name__ == "__main__":
    import doctest

    doctest.testmod()
