
import unittest
import traceback
import os

import aaf

import aaf.datadef
import aaf.component
import aaf.mob
import aaf.essence

sandbox = os.path.join(os.path.dirname(os.path.abspath(__file__)),'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)
    
def chunks(l, n):
    """ Yield successive n-sized chunks from l.
    """
    for i in xrange(0, len(l), n):
        yield l[i:i+n]

class TestFile(unittest.TestCase):
    
    def test_create_picture_essence(self):
        output_aaf = os.path.join(sandbox, 'picture_essence_create.aaf')
        output_xml = os.path.join(sandbox, 'picture_essence_create.xml')
        if os.path.exists(output_aaf):
            os.remove(output_aaf)
        f = aaf.open(output_aaf, 'rw')
        
        
        header = f.header()
        storage = header.storage()
        d = header.dictionary()
        
        picture_mastermob = d.create.MasterMob("Picture Mob 1")
        header.append(picture_mastermob)

        
        rate = "25/1"
        picture_essence = picture_mastermob.create_essence(1,
                                                             media_kind= "picture",
                                                             codec_name="JPEG",
                                                             edit_rate = rate,
                                                             sample_rate = rate, 
                                                             compress=True)
        
        slot = list(picture_mastermob.slots())[0]
        clip = slot.segment()
        source_mob = clip.resolve_ref()
        cdci_desc = source_mob.essence_descriptor
        
        component_width = 8
        horizontal_subsampling = 2 # 2 means 4:2:2
        vertical_subsampling = 1
        color_range = 255
        
        width, height =  720, 540
        size = (width, height)
        
        rect = (width, height, 0, 0)
        cdci_desc.stored_view = (width, height)
        cdci_desc.sampled_view = rect
        cdci_desc.display_view = rect
        cdci_desc.layout = 'MixedFields'
        cdci_desc.line_map = (0,1)
        
        # cdci specific
        cdci_desc.component_width = component_width
        cdci_desc.horizontal_subsampling = horizontal_subsampling
        cdci_desc.vertical_subsampling = vertical_subsampling
        cdci_desc.color_range = color_range
        
        format = picture_essence.get_emptyfileformat()
        
        format['StoredRect'] = rect
        format['SampledRect'] = rect
        format['DisplayRect'] = rect
        format['framelayout'] = cdci_desc.layout
        format['VideoLineMap'] = cdci_desc.line_map
        
        format['CDCICompWidth'] = cdci_desc.component_width
        format['CDCIHorizSubsampling'] = cdci_desc.horizontal_subsampling
        format['CDCIColorRange'] = cdci_desc.color_range
        format['PixelFormat'] = 'YUV'
 
        picture_essence.set_fileformat(format)
        
        
        frames = 4
        
        for i in xrange(frames):
            data = [1 for x in range(width * height * 2)]
            ret= picture_essence.write(data, 1,'UInt8')
            print 'wrote', ret
        picture_essence.complete_write()
        f.save()
        f.save(output_xml)
        f.close()
        
    def test_create_sound_essence(self):
        output_aaf = os.path.join(sandbox, 'sound_essence_create.aaf')
        output_xml = os.path.join(sandbox, 'sound_essence_create.xml')
        if os.path.exists(output_aaf):
            os.remove(output_aaf)
        f = aaf.open(output_aaf, 'rw')
        
        
        header = f.header()
        storage = header.storage()
        d = header.dictionary()
        
        sound_mastermob = d.create.MasterMob("sound Mob 1")

        header.append(sound_mastermob)
        
        
        rateHz = 44100
        rate = "%d/1" % rateHz
         
        sound_essence = sound_mastermob.create_essence(1,
                                                     media_kind= "sound",
                                                     codec_name="WAVE",
                                                     edit_rate = rate,
                                                     sample_rate = rate, 
                                                     compress=False)
         
        
        slot = list(sound_mastermob.slots())[0]
        clip = slot.segment()
        source_mob = clip.resolve_ref()
        WAVEDesc = source_mob.essence_descriptor
        
        format = sound_essence.get_emptyfileformat()
        format['AudioSampleBits'] =  16
        sound_essence.set_fileformat(format)
        
        numSamples = 2 * rateHz / 25 # 2 pal frames in duration.
        samplesToWrite = 10
        
        for c in chunks([1 for i in xrange(numSamples)], samplesToWrite):
            ret = sound_essence.write(c, len(c), 'UInt16')
            #print "wrote", ret
        
        sound_essence.complete_write()

        f.save()
        f.save(output_xml)
        f.close()
        
    def test_create_comp(self):
        
        output_aaf = os.path.join(sandbox, 'comp_essence_create.aaf')
        output_xml = os.path.join(sandbox, 'copm_essence_create.xml')
        if os.path.exists(output_aaf):
            os.remove(output_aaf)
        f = aaf.open(output_aaf, 'rw')
        
        header = f.header()
        storage = header.storage()
        d = header.dictionary()
        
        picture_mastermob1 = d.create.MasterMob("Picture Mob 1")
        picture_mastermob2 = d.create.MasterMob("Picture Mob 2")
        header.append(picture_mastermob1)
        header.append(picture_mastermob2)
        
        sound_mastermob1 = d.create.MasterMob("sound Mob 1")
        sound_mastermob2 = d.create.MasterMob("sound Mob 2")
        header.append(sound_mastermob1)
        header.append(sound_mastermob2)
        
        
        comp = d.create.CompositionMob("Comp Example")
        header.append(comp)
        
        print comp.mobID
        
        audio_sequence = d.create.Sequence("Sound")
        video_sequence = d.create.Sequence("Picture")
        
        edit_rate = "25/1"
        video_slot_num = 1
        video_slot_name = "Video Timeline"
        
        timeline_slot = comp.add_timeline_slot(edit_rate, video_sequence)
        
        
        #clip = picture_mastermob1.create_clip(start =0 , length =10)
        #video_sequence.append_component(clip)
        #clip = picture_mastermob2.create_clip(start = 10, lenght = 10)
        #video_sequence.append_component(clip)
        
        #print timeline_slot
        
        
        
        f.save()
        f.save(output_xml)
        f.close()


if __name__ == '__main__':
    unittest.main()