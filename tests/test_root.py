from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.base
import unittest
import traceback

import os


cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

main_test_file = os.path.join(cur_dir,"files/test_file_01.aaf")
print(main_test_file)
assert os.path.exists(main_test_file)


def iter_mobs(path):
    f = aaf.open(path)

    for m in f.storage.mobs():
        yield m


class TestFile(unittest.TestCase):

    def test_itermobs(self):
        test_file = main_test_file

        for m in iter_mobs(test_file):
            assert m.root is not None
    def test_walk_file(self):
        test_file = main_test_file

        f = aaf.open(test_file)

        header = f.header

        def walk_properties(space, iter_item):

            for item in iter_item:
                value = item
                if isinstance(item, aaf.property.PropertyItem):
                    value = item.value
                    print(space, item.root)
                    assert item.root is not None
                name = ""

                if hasattr(item, 'name'):
                    name = item.name or ""

                #print space,name, value
                s = space + '   '

                if isinstance(value, aaf.base.AAFBase):
                    #print("***", item, value)
                    assert value.root is not None

                if isinstance(value, aaf.base.AAFObject):
                    #print(space, value.root)
                    assert value.root is not None
                    walk_properties(s, value.properties())
                if isinstance(value, aaf.iterator.BaseIterator):
                    print(space,value, value.root)
                    assert value.root is not None
                    walk_properties(s, value)

        walk_properties("", header.properties())

if __name__ == '__main__':
    unittest.main()
