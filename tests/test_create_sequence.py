from __future__ import print_function
import unittest
import traceback
import os

import aaf
import aaf.util


sandbox = os.path.join(os.path.dirname(os.path.abspath(__file__)),'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

class TestCreateSequence(unittest.TestCase):

    def test_create_sequence(self):
        output_aaf = os.path.join(sandbox, 'create_sequence.aaf')
        output_xml = os.path.join(sandbox, 'create_sequence.xml')

        f = aaf.open(output_aaf, "w")

        video_rate = " 30000/1001"

        comp_mob = f.create.CompositionMob()
        sequence = f.create.Sequence("picture")

        timeline_slot = comp_mob.append_new_timeline_slot( video_rate, sequence)

        f.storage.add_mob(comp_mob)
        TAPE_LENGTH  = 1 * 60 *60 * 30
        file_len = 60 * 30
        filler_len = 100
        tape_tc = aaf.util.Timecode(108000, "NonDrop", 30)

        for i in range(10):

            # Make the Tape MOB
            tape_mob = f.create.SourceMob()
            tape_description = f.create.TapeDescriptor()
            tape_mob.essence_descriptor = tape_description

            tape_mob.append_timecode_slot(video_rate, 0, tape_tc, TAPE_LENGTH)
            tape_mob.add_nil_ref(1,TAPE_LENGTH, "picture", video_rate)

            tape_mob.name = "Tape Mob %i" %  i
            f.storage.add_mob(tape_mob)

            # Make a FileMob
            file_mob = f.create.SourceMob()
            file_description = f.create.AIFCDescriptor()
            file_description.summary = b"TEST"
            assert file_description.summary == b"TEST"

            # Make a locator, and attach it to the EssenceDescriptor

            loc = f.create.NetworkLocator()
            loc.path = "AnotherFile.aaf"
            file_description.append_locator(loc)

            file_mob.essence_descriptor = file_description

            source_ref = aaf.util.SourceRef(tape_mob.mobID, 1, 0)
            file_mob.new_phys_source_ref(video_rate, 1, "picture", source_ref, file_len)

            f.storage.add_mob(file_mob)

            # Make the Master MOB

            master_mob = f.create.MasterMob()
            master_mob.name = "Master Mob %i" % i
            source_ref = aaf.util.SourceRef(file_mob.mobID, 1, 0)

            master_mob.new_phys_source_ref(video_rate, 1, "picture", source_ref, file_len)

            f.storage.add_mob(master_mob)

            # Create a SourceClip

            clip = master_mob.create_clip(1)
            sequence.append(clip)

            # Create a filler

            comp_fill = f.create.Filler("picture", filler_len)
            sequence.append(comp_fill)

        f.save()
        f.save(output_xml)
        f.close()

        f = aaf.open(output_aaf, 'r')

        for mob in f.storage.master_mobs():
            print(mob.name)



if __name__ == "__main__":
    unittest.main()
