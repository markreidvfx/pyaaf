from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage

import unittest
import traceback

import os

import uuid

cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

main_test_file = os.path.join(sandbox, 'test_mastermob.aaf')
main_test_file_xml = os.path.join(sandbox, 'test_mastermob.xml')

mob_id = "urn:smpte:umid:060a2b34.01010101.01010f00.13000000.060e2b34.7f7f2a80.5313d268.30a073be"
mob_name  = "test_mastermob"



manufacturer = "MyManufacturer"
model = "MyModel"

form_factor = "VHSVideoTape"
video_signal_type = "PALSignal"
tape_format = "VHSFormat"
tape_length = 3200

NumMobSlots = 4
tape_mob_id = "urn:smpte:umid:060a2b34.01010101.01010f00.13000000.060e2b34.7f7f2a80.531551e8.fee77453"
tape_mob_length = 60
tape_mob_offset = 10
tape_mob_name = "A Tape Mob"
slot_rates = [ 297, 44100, 44100, 25]
slot_defs = ["Picture", "Sound", "Sound", "Picture"]
slot_names = ["VIDEO SLOT", "AUDIO SLOT1", "AUDIO SLOT2", "VIDEO SLOT MXF style"]

class TestFile(unittest.TestCase):

    def setUp(self):
        f = aaf.open(main_test_file, 'w')
        mob = f.create.MasterMob()
        mob.name = mob_name
        mob.mobID = mob_id
        f.storage.add_mob(mob)

        source_mob = f.create.SourceMob()
        source_mob.name = tape_mob_name
        source_mob.mobID = tape_mob_id

        f.storage.add_mob(source_mob)

        tape_description = f.create.TapeDescriptor()

        print(tape_description['ManufacturerID'].value)
        print(tape_description['ManufacturerID'].typedef)

        tape_description['ManufacturerID'].value = manufacturer
        print("~~~", tape_description['ManufacturerID'].value)
        assert tape_description['ManufacturerID'].value == manufacturer
        #tape_description['ManufacturerID'].value = manufacturer + '2'

        tape_description['Model'].value = model
        print("~~~", tape_description['Model'].value)
        tape_description['FormFactor'].value = form_factor
        print("~~~", tape_description['FormFactor'].value)
        tape_description['VideoSignal'].value = video_signal_type
        print("~~~", tape_description['VideoSignal'].value)
        tape_description['TapeFormat'].value = tape_format
        print("~~~", tape_description['TapeFormat'].value)

        print(tape_description['FormFactor'].typedef.elements())
        print(tape_description['VideoSignal'].typedef.elements())
        print(tape_description['TapeFormat'].typedef.elements())
        tape_description['Length'].value = tape_length
        print("~~~", tape_description['Length'].value)

        source_mob.essence_descriptor = tape_description


        for i in range(NumMobSlots):
            source_mob.add_nil_ref(i, tape_mob_length, slot_defs[i], slot_rates[i])

        for i in range(NumMobSlots):
            src_mob = f.create.SourceMob()
            source_ref = aaf.util.SourceRef(source_mob.mobID, i, tape_mob_offset)
            if i == 0:
                src_mob.new_phys_source_ref(slot_rates[i], i, slot_defs[i], source_ref, tape_mob_length)
            else:
                src_mob.append_phys_source_ref(slot_rates[i], i, slot_defs[i], source_ref, tape_mob_length)

            desc = f.create.AIFCDescriptor()
            desc.summary = b"TEST"
            src_mob.essence_descriptor = desc
            src_mob.name = "source mob"
            f.storage.add_mob(src_mob)

            if i == NumMobSlots -1:
                print(mob.add_master_slot_with_sequence(slot_defs[i], i, src_mob, i+1, slot_names[i]))
            else:
                print(mob.add_master_slot(slot_defs[i], i, src_mob, i+1, slot_names[i]))
        #add_master_slot_with_sequence
        f.save()
        f.save(main_test_file_xml)
        #f.close()
    def test_result(self):
        f = aaf.open(main_test_file, 'r')

        assert len(f.storage.master_mobs()) == 1
        mob = f.storage.lookup_mob(mob_id)
        assert mob.name == mob_name

        for i, slot in enumerate(mob.slots()):
            print(slot.name)
            assert slot.name == slot_names[i]

            seg = slot.segment
            print(seg)
            if slot.slotID == NumMobSlots:
                assert isinstance(seg, aaf.component.Sequence)
            else:
                assert isinstance(seg, aaf.component.SourceClip)

                src_mob =  seg.resolve_ref()
                for s in src_mob.slots():
                    tape_mob = s.segment.resolve_ref()
                    tape_description = tape_mob.essence_descriptor
                    print(tape_mob)
                    print(tape_description)
                    print("ManufacturerID =", tape_description['ManufacturerID'].value)
                    assert tape_description['ManufacturerID'].value == manufacturer
                    print("Model", tape_description['Model'].value)
                    assert tape_description['Model'].value == model
                    print("FormFactor", tape_description['FormFactor'].value)



        #assert mob.essence_descriptor['ManufacturerID'].value == manufacturer

if __name__ == '__main__':
    unittest.main()
