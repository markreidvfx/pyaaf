from __future__ import print_function
import aaf
import aaf.util
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.base

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

    def test_lookup(self):
        test_mobID = "urn:smpte:umid:060a2b34.01010101.01010f00.13000000.060e2b34.7f7f2a80.48c9f1f4.2abb0184"

        f = aaf.open(main_test_file)

        mob = f.storage.lookup_mob(test_mobID)

        assert mob.mobID == test_mobID

    def test_lookup_richcmp(self):
        f = aaf.open(main_test_file)

        for mob in f.storage.mobs():
            assert mob == f.storage.lookup_mob(mob.mobID)
            assert mob.mobID == f.storage.lookup_mob(mob.mobID).mobID

    def test_auid(self):

        for x in range(10):
            u = uuid.uuid4()
            auid = aaf.util.AUID(u)
            assert auid == u
            assert u == auid
            assert u == auid.to_UUID()


        smpte_ul = aaf.util.AUID.from_urn_smpte_ul("urn:smpte:ul:060e2b34.01040101.0e040301.02000000")
        print("urn:smpte:ul:060e2b34.01040101.0e040301.02000000")
        print(smpte_ul.to_urn_smpte_ul())
        print("   ",smpte_ul)

        assert smpte_ul.to_urn_smpte_ul() == "urn:smpte:ul:060e2b34.01040101.0e040301.02000000"



if __name__ == '__main__':
    unittest.main()
