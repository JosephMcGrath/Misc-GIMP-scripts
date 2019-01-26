# -*- coding: utf-8 -*-


def hex_counter(number: int, pad: int = 5) -> str:
    """
    Converts an integet into hex, formatted as a string. Intended for more
    compact file names.
    
    >>> hex_counter(1, 1)
    '1'
    
    >>> hex_counter(999, 5)
    '003e7'
    
    >>> hex_counter(999, 2)
    '3e7'
    """
    return str(hex(number))[2:].zfill(pad)


if __name__ == "__main__":
    import doctest

    doctest.testmod()
