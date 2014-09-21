from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.base
import aaf.util
import unittest
import traceback

import os


cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

main_test_file = os.path.join(cur_dir,"files/test_file_01.aaf")

assert os.path.exists(main_test_file)

class TestMobID(unittest.TestCase):
        
    
    def test_setting_property(self):
        
        f = aaf.open(main_test_file)
        
        mob = f.storage.composition_mobs()[0]
        
        mob_id = mob['MobID'].value
        
        d = mob_id.to_dict()
        d['instanceLow'] = 10
        d['length'] = 2

        mob['MobID'].value = d
        
        assert mob['MobID'].value != mob_id
        
        mob['MobID'].value = mob_id
        
        assert mob['MobID'].value == mob_id
        
        mob_id2 = aaf.util.MobID.from_dict(d)
        
        assert mob_id2 != mob_id
        
        mob['MobID'].value = str(mob_id2)
        assert mob['MobID'].value == mob_id2 
    
    def test_from_methods(self):
        f = aaf.open(main_test_file)
        
        mob = f.storage.composition_mobs()[0]
        
        mob_id = mob.mobID
        
        assert mob_id == aaf.util.MobID(mob_id.to_list())
        assert mob_id == aaf.util.MobID(mob_id.to_dict())
        assert mob_id == aaf.util.MobID(str(mob_id))
        
        l = mob_id.to_list()
        l[5] = 10
        assert mob_id != aaf.util.MobID(l)
        
        d = mob_id.to_dict()
        d['SMPTELabel'] = [0x10 for i in range(12)]
        assert mob_id != aaf.util.MobID(d)


if __name__ == '__main__':
    unittest.main()