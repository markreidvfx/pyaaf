from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.base
import aaf.util
import unittest
import traceback

import os


cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

main_test_file = os.path.join(cur_dir,"files/test_file_01.aaf")
print(main_test_file)

Counter = 0
def progress_callback():
    global Counter
    print ("Progress Counter =", Counter)
    Counter += 1
    #raise ValueError()


class TestFile(unittest.TestCase):
    def test_basic(self):

        aaf.util.set_progress_callback(progress_callback)

        f = aaf.open(main_test_file)

        global Counter

        value  = Counter
        assert Counter > 0

        out_test_file = os.path.join(sandbox, 'test_progress_callback.aaf')

        f.save(out_test_file)

        assert Counter > value

        f.close()


        print("Final", Counter, "Before save", value)

if __name__ == '__main__':
    unittest.main()
