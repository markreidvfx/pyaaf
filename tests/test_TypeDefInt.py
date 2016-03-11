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

cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)



class TestTypeDefInt(unittest.TestCase):


    def test_typedef_UInt8(self):

        f = aaf.open(None, 't')

        typdef = f.dictionary.lookup_typedef("UInt8")

        property_value = typdef.create_property_value(1)

        assert property_value.value == 1

        property_value.value = 2

        assert property_value.value == 2

        try:
            property_value = typdef.create_property_value(-1)
        except OverflowError:
            pass
        else:
            raise

        assert typdef.is_signed() == False

    def test_typedef_Int8(self):
        f = aaf.open(None, 't')

        typdef = f.dictionary.lookup_typedef("Int8")

        property_value = typdef.create_property_value(10)

        assert property_value.value == 10

        property_value.value = -2

        assert property_value.value == -2


        try:
            property_value = typdef.create_property_value(1000)

        except OverflowError:
            pass
        else:
            raise

        assert typdef.is_signed() == True


if __name__ == "__main__":
    unittest.main()
