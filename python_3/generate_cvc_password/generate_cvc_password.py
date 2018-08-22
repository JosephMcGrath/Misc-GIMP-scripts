# -*- coding: utf-8 -*-

import random

def make_cvc(n_set = 4):
    ret = []
    vowels = [v for v in 'aeiou']
    consonants = [c for c in 'bcdfghjklmnpqrstvwxyz']
    
    for i in range(n_set):
        ret.append(random.choice(consonants) +
                   random.choice(vowels) +
                   random.choice(consonants)
                  )
    ret = '-'.join(ret)
    
    return ret

#==============================================================================
if __name__ == "__main__":
    print(make_cvc(4))
