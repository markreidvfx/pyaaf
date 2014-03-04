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

mob_id = "urn:smpte:umid:060a2b34.01010101.01010f00.13000000.060e2b34.7f7f2a80.5313d268.30a073be"
mob_name  = "test_mastermob"

manufacturer = "MyManufacturer"
model = "MyModel"

form_factor = "VHSVideoTape"
video_signal_type = "PALSignal"
tape_format = "VHSFormat"
tape_length = 3200

class TestFile(unittest.TestCase):
    
    def setUp(self):
        f = aaf.open(main_test_file, 'w')
        mob = f.create.MasterMob()
        mob.name = mob_name
        mob.mobID = mob_id
        f.storage.add_mob(mob)
        
        source_mob = f.create.SourceMob()
        tape_description = f.create.TapeDescriptor()
        source_mob.essence_descriptor = tape_description

        tape_description['ManufacturerID'].value = manufacturer
        print tape_description['ManufacturerID'].value
        tape_description['Model'].value = model
        print tape_description['Model'].value
        tape_description['FormFactor'].value = form_factor
        print tape_description['FormFactor'].value
        tape_description['VideoSignal'].value = video_signal_type
        print tape_description['VideoSignal'].value
        tape_description['TapeFormat'].value = tape_format
        print tape_description['TapeFormat'].value
        
        #print tape_description['TapeFormat'].property_value().typedef().elements()
        tape_description['Length'].value = tape_length
        print tape_description['Length'].value
        
        f.save()
        f.close()
    def test_result(self):
        f = aaf.open(main_test_file, 'r')
        
        mob = f.storage.lookup_mob(mob_id)
        assert mob.name == mob_name
    
if __name__ == '__main__':
    unittest.main()