import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage

import unittest
import traceback

import os


cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

main_test_file = os.path.join(cur_dir,"files/test_file_01.aaf")

class TestFile(unittest.TestCase):
    
    def test_lookup(self):
        test_mobID = "urn:smpte:umid:060a2b34.01010101.01010f00.13000000.060e2b34.7f7f2a80.48c9f1f4.2abb0184"
        
        f = aaf.open(main_test_file)
        
        mob = f.storage.lookup_mob(test_mobID)
        
        assert mob.mobID == test_mobID
        
if __name__ == '__main__':
    unittest.main()
