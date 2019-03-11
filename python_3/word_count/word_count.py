# -*- coding: utf-8 -*-

import re
import collections
import datetime


def split_words(text: str) -> list:
    """Splits a string on whitespace."""
    return [x for x in re.split(r"[^\w\']+", text) if x]


def word_frequency(text: str) -> collections.Counter:
    """Counts the frequency of different words in a string."""
    return collections.Counter([x.lower() for x in split_words(text)])


def word_count(text: str) -> int:
    """Count the total number of words in a string."""
    return len(split_words(text))


def read_text(path: str) -> str:
    """Reads a file into a string."""
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    return "".join(text)


def file_word_count(path):
    """Counts the number of words in a file."""
    return word_count(read_text(path))
