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

        ame_id = AUID.from_urn_smpte_ul("urn:smpte:ul:060e2b34.01040101.0e040301.01000000")
        typedef_pairs = [('did', 'UInt8'),('sdid', 'UInt8')]
        ame_typdef = aaf.define.TypeDefRecord(f, typedef_pairs, ame_id, 'AvidManifestElement')
        f.dictionary.register_def(ame_typdef)

        ama_id = AUID.from_urn_smpte_ul("urn:smpte:ul:060e2b34.01040101.0e040402.01000000")
        ama_typdef = aaf.define.TypeDefVariableArray(f, ame_typdef, ama_id, "AvidManifestArray")
        f.dictionary.register_def(ama_typdef)

        class_id = AUID.from_urn_smpte_ul("urn:smpte:ul:060e2b34.02060101.0d010101.01015c00")
        parent_classdef = f.dictionary.lookup_classdef("DataEssenceDescriptor")
        ancd_classdef = aaf.define.ClassDef(f,
                                    class_id, parent_classdef, "ANCDataDescriptor", True)

        prop_id = AUID.from_urn_smpte_ul("urn:smpte:ul:060e2b34.01010101.0e040101.01010105")
        ancd_classdef.register_optional_propertydef(ama_typdef, prop_id, 'ManifestArray')

        f.dictionary.register_def(ancd_classdef)


        desc = f.create.ANCDataDescriptor()
        self.assertEqual(desc.classdef().name, 'ANCDataDescriptor')

        desc['Length'].value = 10
        self.assertEqual(desc['Length'].value, 10)

        manifest = [{'did':0, 'sdid':1}, {'did':1, 'sdid':2}, {'did':3, 'sdid':4}]
        desc['ManifestArray'].value = manifest
        self.assertEqual(list(desc['ManifestArray'].value), manifest)

        self.assertRaises(RuntimeError, f.create.SubDescriptor)

        f.save("test.xml")


if __name__ == "__main__":
    unittest.main()
