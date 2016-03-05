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

class TestTypeDefSet(unittest.TestCase):
    def test_typedef_set(self):
        f = aaf.open()
        marker = f.create.DescriptiveMarker()
        elements = [1,2,3]
        marker.set_described_slot_ids([1,2,3])
        self.assertTrue(elements == list(marker['DescribedSlots'].value))
        self.assertTrue(marker['DescribedSlots'].typedef.size(
                    marker['DescribedSlots'].property_value()) == len(elements))

if __name__ == "__main__":
    unittest.main()
