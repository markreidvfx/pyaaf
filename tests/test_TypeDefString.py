from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.component

import unittest
import os

from aaf.util import AUID

cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

class TestTypeString(unittest.TestCase):


    def test_typedef(self):
        type_name = "TEST_String"
        type_id = AUID.from_list([0xb9da6c9e, 0x2b3c, 0x11d4, 0x8e, 0x50, 0x0, 0x90, 0x27, 0xdf, 0xcc, 0x26])

        prop_name = "STR Property Name"
        prop_id = AUID.from_list([0xb9da6c9f, 0x2b3c, 0x11d4, 0x8e, 0x50, 0x0, 0x90, 0x27, 0xdf, 0xcc, 0x26])
        f = aaf.open()

        string_typedef = aaf.define.TypeDefString(f, type_id, type_name)
        print(string_typedef)

        f.dictionary.register_def(string_typedef)

        mob_classdef = f.dictionary.lookup_classdef("Mob")

        mob_classdef.register_optional_propertydef(string_typedef, prop_id, prop_name)

        test_value = "Test Value"
        mob = f.create.MasterMob()
        mob[prop_name].value = test_value

        f.storage.add_mob(mob)

        self.assertEqual(mob[prop_name].value, test_value)



if __name__ == "__main__":
    unittest.main()
