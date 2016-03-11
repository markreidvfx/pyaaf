from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.component
import aaf.util

import traceback
import unittest
import os

from aaf.util import AUID, MobID

cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

class TestSourceClip(unittest.TestCase):

    def test_basic(self):

        test_file = os.path.join(sandbox, "test_SourceClip.aaf")

        f = aaf.open(None, 't')

        source_mob = f.create.SourceMob()
        f.storage.add_mob(source_mob)
        slot = source_mob.add_nil_ref(1, 100, "picture", "25/1")

        source_ref = aaf.util.SourceRef()
        source_ref.mob_id = source_mob.mobID
        source_ref.slot_id = slot.slotID
        source_ref.start_time = 10
        #source_ref.

        source_clip = f.create.SourceClip("picture", 10, source_ref)

        assert source_clip.source_ref.mob_id == source_mob.mobID
        print(source_clip.source_ref.slot_id)

        assert source_clip.source_ref.slot_id == slot.slotID

        s = str(source_clip.source_ref)

        #slot = source_clip.resolve_slot()

        assert source_clip.start_time == 10
        source_clip.start_time = 5
        assert source_clip.start_time == 5

        # this wont reslove unless sourclip is actually added to file
        #assert source_clip.resolve_ref() == source_mob




if __name__ == "__main__":
    unittest.main()
