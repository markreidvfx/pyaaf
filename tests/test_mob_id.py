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

test_mob_id = [0x06, 0x0c, 0x2b, 0x34, 0x02, 0x05, 0x11, 0x01, 0x01, 0x00, 0x10, 0x00, 0x13,
                               0x00, 0x00, 0x00, 0xda, 0x5a, 0xb5, 0xf4, 0x04, 0x05, 0x11, 0xd4, 0x8e, 0x3d, 0x00, 0x90, 0x27, 0xdf, 0xca, 0x7c]

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
        print(mob.mobID)
        assert mob_id == aaf.util.MobID(mob_id.to_list())
        assert mob_id == aaf.util.MobID(mob_id.to_dict())
        assert mob_id == aaf.util.MobID(str(mob_id))

        l = mob_id.to_list()
        l[5] = 10
        assert mob_id != aaf.util.MobID(l)

        d = mob_id.to_dict()
        d['SMPTELabel'] = [0x10 for i in range(12)]
        assert mob_id != aaf.util.MobID(d)

    def test_sourclip(self):

        f = aaf.open(main_test_file)

        mob = f.storage.master_mobs()[0]

        clip = mob.create_clip()

        vv = clip['SourceID'].value
        clip['SourceID'].value = vv

        assert clip['SourceID'].value == vv
        assert clip['SourceID'].value == mob.mobID
        assert clip.mob_id == vv

        clip.mob_id = test_mob_id
        assert clip['SourceID'].value == test_mob_id
        print(test_mob_id)
        print(clip['SourceID'].value.to_list())
        assert clip['SourceID'].value.to_list() == test_mob_id
        assert clip.mob_id == aaf.util.MobID(test_mob_id).to_dict()

    def test_umid(self):
        umid = u"0x060A2B340101010101010F001300000051D2066BDCF6003E060E2B347F7F2A80"

        mob_id = aaf.util.MobID()

        mob_id.umid = umid
        assert mob_id.umid == umid
        assert mob_id == umid

        f = aaf.open()
        mob = f.create.MasterMob()
        mob.umid = umid
        print(umid)
        print(mob.mobID)
        print(aaf.util.MobID(umid))
        assert mob.umid == umid

    def test_int(self):
        for i in range(1000):
            m = aaf.util.MobID()
            m.int = i
            assert m.int == i


if __name__ == '__main__':
    unittest.main()
