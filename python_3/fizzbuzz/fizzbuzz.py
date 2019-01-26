# -*- coding: utf-8 -*-


def single_fizzbuzz(val, key_in):
    temp = "".join([y for x, y in key_in if val % x == 0])
    if temp == "":
        temp = val
    return temp


def fizzbuzz(to_val, key_in=[(3, "Fizz"), (5, "Buzz")]):
    return [single_fizzbuzz(x, key_in) for x in range(1, to_val + 1)]

    # ==============================================================================
    print(fizzbuzz(60, [(3, "Fizz"), (5, "Buzz"), (8, "Hat")]))
