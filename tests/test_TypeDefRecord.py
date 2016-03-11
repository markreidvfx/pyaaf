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

main_test_file = os.path.join(sandbox, 'test_TypeDef.aaf')

TypeId_Mixed = AUID.from_list([0xed9cbe2f, 0x1a42, 0x420c, 0x95, 0x2e, 0x7b, 0x23, 0xad, 0xbb, 0xc4, 0x79 ])

class TypeDefRecord(unittest.TestCase):
    def test_basic(self):
        f = aaf.open(main_test_file, 'w')

        try:
            typdef = aaf.define.TypeDefRecord(f, [('some_int')], TypeId_Mixed, 'MixedRecord')

        except ValueError:
            pass
            print(traceback.format_exc())
        else:
            raise

        auid_typedef = f.dictionary.lookup_typedef("AUID")

        record_name_typedef_pairs = [('int64', 'int64'),
                                      ('uint64', 'uint64'),
                                      ("auid", auid_typedef),
                                      ("UInt8Array8", "UInt8Array8"),
                                      ("FilmType", "FilmType")

                                      ]

        typedef = aaf.define.TypeDefRecord(f, record_name_typedef_pairs, TypeId_Mixed, 'MixedRecord')

        print(typedef.keys(), typedef.typedef_dict())


if __name__ == "__main__":
    unittest.main()
