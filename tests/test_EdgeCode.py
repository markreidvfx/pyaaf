from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.component

import unittest
import traceback

import os

import uuid

cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)



class TestEdgeCode(unittest.TestCase):

    def test_basic(self):
        test_file = os.path.join(sandbox, "test_EdgeCode.aaf")
        f = aaf.open(test_file, 'w')

        mob = f.create.CompositionMob()

        f.storage.add_mob(mob)

        edge_code_header = 'BOB'

        # manually initialize
        edgecode =  aaf.component.EdgeCode(f, header=edge_code_header)

        edgecode['Length'].value = 10

        mob.append_new_timeline_slot("0/1", edgecode, 0, "edgecode", 0)

        #print(edgecode.header)
        assert edgecode.header == edge_code_header


        # test create interface
        edgecode2 = f.create.EdgeCode(100, header=edge_code_header)

        assert edgecode2.header == edge_code_header
        assert edgecode2['Length'].value == 100


        edgecode.header = u"BOB2"

        assert edgecode.header == "BOB2"


        f.save()
        f.close()


        f = aaf.open(test_file, 'r')

        mob = f.storage.composition_mobs()[0]

        edgecode =  mob.slots()[0].segment

        assert edgecode.header == "BOB2"




if __name__ == "__main__":
    unittest.main()
