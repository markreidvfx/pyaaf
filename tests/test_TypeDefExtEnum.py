from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.component
import aaf.util

import traceback

from aaf.util import AUID, MobID

import unittest
import os

cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

main_test_file = os.path.join(sandbox, 'test_TypeDefEnum.aaf')

TypeId_Mixed = AUID.from_list([0xed9cbe2f, 0x1a42, 0x420c, 0x95, 0x2e, 0x7b, 0x23, 0xad, 0xbb, 0xc4, 0x79 ])

class TypeDefExtEnum(unittest.TestCase):
    def test_basic(self):
        f = aaf.open(main_test_file, 'w')

        mob = f.create.CompositionMob()
        mob.usage_code = 'Usage_TopLevel'

        self.assertEqual(mob['UsageCode'].value, 'Usage_TopLevel')
        mob['UsageCode'].value = 'Usage_SubClip'

        f.storage.add_mob(mob)
        f.save()
        f.close()

        f = aaf.open(main_test_file, 'r')
        mob = f.storage.mobs()[0]

        self.assertEqual(mob['UsageCode'].value, 'Usage_SubClip')

if __name__ == "__main__":
    unittest.main()
