import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage

import unittest
import traceback

import os

import uuid

cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

main_test_file = os.path.join(sandbox, 'test_mastermob.aaf')

mob_id = "urn:smpte:umid:060a2b34.01010101.01010f00.13000000.060e2b34.7f7f2a80.5313d268.30a073be"
mob_name  = "test_mastermob"

class TestFile(unittest.TestCase):
    
    def setUp(self):
        f = aaf.open(main_test_file, 'w')
        mob = f.create.MasterMob()
        mob.name = mob_name
        mob.mobID = mob_id
        f.storage.add_mob(mob)
        f.save()
        f.close()
    def test_result(self):
        f = aaf.open(main_test_file, 'r')
        
        mob = f.storage.lookup_mob(mob_id)
        assert mob.name == mob_name
    
if __name__ == '__main__':
    unittest.main()