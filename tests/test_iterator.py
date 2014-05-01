from __future__ import print_function
import aaf
import aaf.util
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.base
import aaf.component

import unittest
import traceback

import os

import uuid


cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

main_test_file = os.path.join(cur_dir,"files/test_file_01.aaf")


def iter_count(iterable):
    i = 0
    while True:
        result = next(iterable, None)
        if not result:
            break
        i += 1 
    return i   



class TestFile(unittest.TestCase):
    
    def test_len(self):
        f = aaf.open(main_test_file)
        iterable = f.storage.mobs()
        
        assert len(iterable) == 199
    
        count = 0 
        for i, item in enumerate(iterable):
            #print item
            assert len(iterable) == 199
            count += 1
            
        assert count == len(iterable)
        assert len(iterable) == 199
        
    def test_negative_index(self):
        f = aaf.open(main_test_file)
        iterable = f.storage.mobs()
        
        
        last_item = iterable[len(iterable)-1]
        assert last_item == iterable[-1]
        
        try:
            iterable[-10000]
        except IndexError:
            pass
        else:
            raise
        
        for i in range(len(iterable)):
            assert iterable[i] == iterable[i-len(iterable)]
            
    def test_slice(self):
        f = aaf.open(main_test_file)
        iterable = f.storage.mobs()
        
        
        s = iterable[1:10]
        l = []
        for i in range(1, 10):
            l.append(iterable[i])
        
        assert s == l
        
        s = iterable[100:-10:2]
        
        l = []
        
        for i in range(100, len(iterable)-10, 2):
            l.append(iterable[i])
        
        assert s == l
        
        l = iterable[-1000: 1000]
        
        
    def test_skip(self):
        f = aaf.open(main_test_file)
        iterable = f.storage.mobs()
        
        assert len(iterable) == 199
        
        
        skip_amount = 100
        iterable.skip(skip_amount)
        
        assert iter_count(iterable) == 199 - skip_amount
        
        iterable.reset()
        
        assert len(iterable) == 199
        
        
        iterable.skip(skip_amount)
        
        try:
            iterable.skip(1000)
        except IndexError:
            pass
        else:
            raise
        
        assert iter_count(iterable) == 199 - skip_amount
            
        
if __name__ == '__main__':
    unittest.main()
