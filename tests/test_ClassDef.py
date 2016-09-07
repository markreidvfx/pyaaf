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

class TestClassDef(unittest.TestCase):

    def test_classdef(self):

        f = aaf.open()
        class_id = AUID.from_urn_smpte_ul("urn:smpte:ul:060e2b34.02060101.0d010101.01015900")
        parent_classdef = f.dictionary.lookup_classdef("InterchangeObject")
        sub_descriptor_classdef = aaf.define.ClassDef(f,
                                     class_id, parent_classdef, "SubDescriptor", False)

        f.dictionary.register_def(sub_descriptor_classdef)

        class_id = AUID.from_urn_smpte_ul("urn:smpte:ul:060e2b34.02060101.0d010101.01015c00")
        parent_classdef = f.dictionary.lookup_classdef("DataEssenceDescriptor")
        ancd_classdef = aaf.define.ClassDef(f,
                                    class_id, parent_classdef, "ANCDataDescriptor", True)

        f.dictionary.register_def(ancd_classdef)

        # f.save("test.xml")


if __name__ == "__main__":
    unittest.main()
