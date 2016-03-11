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

mob_id = "urn:smpte:umid:060a2b34.01010101.01010f00.13000000.060e2b34.7f7f2a80.5313d268.30a073be"

main_test_file = os.path.join(sandbox, 'test_OperationGroup.aaf')
main_test_file_xml = os.path.join(sandbox, 'test_OperationGroup.xml')

test_category = "0d010102-0101-0100-060e-2b3404010101"

test_effectID = "D15E7611-FE40-11d2-80A5-006008143E6F"
test_parmID =  "C7265931-FE57-11d2-80A5-006008143E6F"

point_values = [.2, .3, 1.0]

class TestFile(unittest.TestCase):

    def setUp(self):
        f = aaf.open(main_test_file, 'w')


        # Create a New Parameter Definition
        typedef = f.dictionary.lookup_typedef("Rational")
        param = aaf.define.ParameterDef(f, test_parmID, "testParam", "this is a test param", typedef)

        param['DisplayUnits'].value = "Furlongs per Fortnight"
        f.dictionary.register_def(param)

        # Create a New Operation Definition
        op_def = aaf.define.OperationDef(f, test_effectID, "tessOpDef", "this is just a test")
        op_def.media_kind = "picture"
        op_def['IsTimeWarp'].value = "False"
        op_def['NumberInputs'].value = 3
        op_def['Bypass'].value = 1

        f.dictionary.register_def(op_def)

        # Added Parameter Definition to Operation Definition
        op_def.add_parameterdef(param)

        interpdef = f.dictionary.lookup_interpolatordef("Linear")
        f.dictionary.register_def(interpdef)


        comp_mob = f.create.CompositionMob()

        comp_mob.name = "OperationGroupTest"
        comp_mob.mobID = mob_id

        for i in range(2):
            opgroup = aaf.component.OperationGroup(f, "picture", 10, op_def)
            filler = f.create.Filler("picture", 10)

            varying_value = aaf.component.VaryingValue(f, param, interpdef)


            p = varying_value.add_point(0, 1)
            print('original:', p['Value'].value)
            p['Value'].value = "1/255"
            print("new->", p['Value'].value)

            p['Value'].value = (1,8)
            print("new->", p['Value'].value)

            p['Value'].value = [1,9]
            print("new->", p['Value'].value)

            p['Value'].value = 5.3121323333423
            print("new->", float(p['Value'].value))

            p.value = point_values[0]

            varying_value.add_point(.5, point_values[1])
            varying_value.add_point(1, point_values[2])

            opgroup.add_parameter(varying_value)

            source_ref = aaf.util.SourceRef(None, 0, 0)
            source_clip = aaf.component.SourceClip(f, 'picture', 10, source_ref)

            opgroup.render = source_clip

            comp_mob.append_new_timeline_slot("2997/100", opgroup, i+1, "slot_%i" % i, 0)

        f.storage.add_mob(comp_mob)

        f.save()
        f.save(main_test_file_xml)

    def test_file(self):
        f = aaf.open(main_test_file, 'r')
        mob = f.storage.lookup_mob(mob_id)

        for slot in mob.slots():
            for i, p in enumerate(slot.segment.parameter['testParam'].points()):
                assert point_values[i] ==  float(p.value)

if __name__ == "__main__":
    unittest.main()
