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

LOG = ""    

def diagnostic_output_callback(message):
    global LOG
    LOG += message


class TestDiagnosticOutput(unittest.TestCase):
    
    # This Test only works on debug builds
    def test_basic(self):
        
        aaf.util.set_diagnostic_output_callback(diagnostic_output_callback)
        
        test_file = os.path.join(sandbox, "test_DiagnosticOutput.aaf")
        
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
        # seq = f.create.Sequence("picture")
        # timeline.segment = seq
        
        mob = f.create.MasterMob()
        
        mob.append_slot(timeline)
        
        f.storage.add_mob(mob)
        
        try:
            f.save()
        except:
            print(traceback.format_exc())
            
        global LOG
        # there should be something in the log
        assert len(LOG)
        
        print("Diagnostic Log:\n")
        print(LOG)
        
        print("A stack track and a diagnostic should print out, this is corrrect!")


if __name__ == "__main__":
    unittest.main()