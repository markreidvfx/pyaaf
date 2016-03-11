from __future__ import print_function
import aaf
import aaf.util
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.base
import aaf.component

import unittest
import traceback

import os

import uuid


cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

main_test_file = os.path.join(cur_dir,"files/retime.aaf")



class TestFile(unittest.TestCase):

    def test_read_curve(self):
        f = aaf.open(main_test_file, 'r')


        print("iter")
        for i, item in enumerate(f.storage.toplevel_mobs()):
            print(i, item)


        comp = f.storage.toplevel_mobs()[0]

        print(comp)


        seqs = [item.segment for item in comp.slots()]
        print(seqs)



        op_group = seqs[1].components()[0]
        print(op_group)

        speed_map = None
        offset_map = None


        speed_map = op_group.parameter['PARAM_SPEED_MAP_U']
        offset_map = op_group.parameter['PARAM_SPEED_OFFSET_MAP_U']

        print(speed_map['PointList'].value)


        print(speed_map.count())


        print(speed_map.interpolation_def().name)

        for p in speed_map.points():
            print("  ", float(p.time), float(p.value), p.edit_hint)
            for prop in p.point_properties():
                print("    ", prop.name, prop.value, float(prop.value))

        print(offset_map.interpolation_def().name)
        for p in offset_map.points():
            edit_hint =  p.edit_hint
            time = p.time
            value = p.value

            pass
            #print "  ", float(p.time), float(p.value)


        for i in range(100):
            float(offset_map.value_at("%i/100" % i))



        # Test file PARAM_SPEED_MAP_U is AvidBezierInterpolator
        # currently no implement for value_at
        try:
            speed_map.value_at(.25)
        except NotImplementedError:
            pass
        else:
            raise



if __name__ == '__main__':
    unittest.main()
