import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.component
import aaf.util

import unittest
import os

cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)
    
main_test_file = os.path.join(sandbox, 'test_TypeDefVariableArray.aaf')


TEST_VA_TYPE_ID = aaf.util.AUID.from_list([0x47240c2e, 0x19d, 0x11d4, 0x8e, 0x3d, 0x0, 0x90, 0x27, 0xdf, 0xca, 0x7c])

TEST_PROP_ID = aaf.util.AUID.from_list([ 0x47240c2f, 0x19d, 0x11d4, 0x8e, 0x3d, 0x0, 0x90, 0x27, 0xdf, 0xca, 0x7c ])

class TypeDefVariableArray(unittest.TestCase):
    
    def test_basic(self):
        
        f = aaf.open(main_test_file, 'w')
        
        
        element_type = f.dictionary.lookup_typedef("Int16")
        variable_array = aaf.define.TypeDefVariableArray(f, element_type, TEST_VA_TYPE_ID, "TEST_VA_TYPE_ID")
        
        assert variable_array.name == "TEST_VA_TYPE_ID"
        assert variable_array.auid == TEST_VA_TYPE_ID
        
        component_classdef = f.dictionary.lookup_classdef('Component')
        
        # find typedef we added to dictionary
        variable_array = f.dictionary.lookup_typedef("TEST_VA_TYPE_ID")
        
        # add a New Optional property to Components classes
        propery_def = component_classdef.register_optional_propertydef(variable_array, TEST_PROP_ID, "TEST_PROP")
        
        assert propery_def.name == "TEST_PROP"
        
        



if __name__ == "__main__":
    unittest.main()