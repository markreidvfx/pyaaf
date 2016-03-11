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

class TestTimelineMobSlot(unittest.TestCase):

    def test_basic(self):

        test_file = os.path.join(sandbox, "test_TimelineMobSlot.aaf")

        f = aaf.open(test_file, 'w')

        timeline = f.create.TimelineMobSlot()

        timeline.mark_in = 1
        assert timeline.mark_in == 1
        timeline.mark_in = 2
        assert timeline.mark_in == 2

        timeline.mark_out = 100
        assert timeline.mark_out == 100
        timeline.mark_out = 10
        assert timeline.mark_out == 10

        # File won't save unless MobSlot has a segment
        seq = f.create.Sequence("picture")
        timeline.segment = seq

        mob = f.create.MasterMob()

        mob.append_slot(timeline)

        f.storage.add_mob(mob)


        f.save()
        f.close()

        f = aaf.open(test_file, 'r')

        mob = f.storage.master_mobs()[0]

        timeline = mob.slots()[0]

        print(timeline)

        assert timeline.mark_in == 2
        assert timeline.mark_out == 10

        f.close()

if __name__ == "__main__":
    unittest.main()
