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



class TestFile(unittest.TestCase):
    
    def test_len(self):
        f = aaf.open(main_test_file)
        
        
        iterable = f.storage.mobs()
        
        assert len(iterable) == 199
    
        count = 0 
        for i, item in enumerate(iterable):
            print item
            assert len(iterable) == 199
            count += 1
            
        assert count == len(iterable)
        assert len(iterable) == 199
        
        
if __name__ == '__main__':
    unittest.main()
