# -*- coding: utf-8 -*-

import random


class markov_chain:
    def __init__(self, seq: list = []):

        self.chain = {}

        if seq:
            self.add(seq)

    def add(self, seq: list):
        """
        Add a list of items to the probability function.
        """

        for word_1, word_2 in self.__make_pairs__(seq):
            if word_1 in self.chain.keys():
                self.chain[word_1].append(word_2)
            else:
                self.chain[word_1] = [word_2]

    def add_text(self, text: str):
        """
        Splits up text and adds it to the probability function.
        """
        self.add(text.split())

    def __make_pairs__(self, seq):
        """
        Turns a sequence into a set of pairs.
        """
        for i in range(len(seq) - 1):
            yield (seq[i], seq[i + 1])

    def output(self, n: int = 30, start=None) -> str:
        """
        Produces an n-word output from the current probability function.
        """

        if not start:
            out = [random.choice(list(self.chain.keys()))]
        else:
            out = [start]

        for i in range(n):
            out.append(random.choice(self.chain[out[-1]]))

        return " ".join(out)
