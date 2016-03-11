from __future__ import print_function
import unittest
import traceback
import os

import aaf

import aaf.define
import aaf.component
import aaf.mob
import aaf.essence

sandbox = os.path.join(os.path.dirname(os.path.abspath(__file__)),'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

def chunks(l, n):
    """ Yield successive n-sized chunks from l.
    """
    for i in range(0, len(l), n):
        yield l[i:i+n]

class TestFile(unittest.TestCase):

    def test_create_picture_essence(self):
        output_aaf = os.path.join(sandbox, 'picture_essence_create.aaf')
        output_xml = os.path.join(sandbox, 'picture_essence_create.xml')
        if os.path.exists(output_aaf):
            os.remove(output_aaf)
        f = aaf.open(output_aaf, 'rw')


        header = f.header
        storage = f.storage
        d = f.dictionary

        picture_mastermob = d.create.MasterMob("Picture Mob 1")
        storage.add_mob(picture_mastermob)


        rate = "25/1"
        picture_essence = picture_mastermob.create_essence(1,
                                                             media_kind= "picture",
                                                             codec_name="JPEG",
                                                             edit_rate = rate,
                                                             sample_rate = rate,
                                                             compress=True)

        slot = list(picture_mastermob.slots())[0]
        clip = slot.segment
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

        for i in range(frames):
            data = [1 for x in range(width * height * 3)] # Not sure how to calculate size, this is to big but works
            ret= picture_essence.write(data, 1,'UInt8')
            print('wrote', ret)
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


        header = f.header
        storage = f.storage
        d = f.dictionary

        sound_mastermob = d.create.MasterMob("sound Mob 1")

        storage.add_mob(sound_mastermob)


        rateHz = 44100
        rate = "%d/1" % rateHz

        sound_essence = sound_mastermob.create_essence(1,
                                                     media_kind= "sound",
                                                     codec_name="WAVE",
                                                     edit_rate = rate,
                                                     sample_rate = rate,
                                                     compress=False)


        slot = list(sound_mastermob.slots())[0]
        clip = slot.segment
        source_mob = clip.resolve_ref()
        WAVEDesc = source_mob.essence_descriptor

        format = sound_essence.get_emptyfileformat()
        format['AudioSampleBits'] =  16
        sound_essence.set_fileformat(format)

        numSamples = int(20 * rateHz / 25) # 2 pal frames in duration.
        samplesToWrite = 10

        for c in chunks([1 for i in range(numSamples)], samplesToWrite):
            ret = sound_essence.write(c, len(c), 'UInt16')
            #print "wrote", ret

        sound_essence.complete_write()

        f.save()
        f.save(output_xml)
        f.close()

    def test_pulldown(self):
        output_aaf = os.path.join(sandbox, 'pulldown_create.aaf')
        output_xml = os.path.join(sandbox, 'pulldown_create.xml')
        if os.path.exists(output_aaf):
            os.remove(output_aaf)
        f = aaf.open(output_aaf, 'rw')

        header = f.header
        d = f.dictionary


        source_mob = d.create.SourceMob()
        source_mob.name = "IMG"

        source_mob.add_nil_ref(1, 39, 'picture',"23976/1000" )
        f.storage.add_mob(source_mob)

        desc = d.create.ImportDescriptor()
        source_mob.essence_descriptor = desc

        timeline = d.create.TimelineMobSlot()
        timeline.editrate = "23976/1000"
        timeline.origin = 0
        timeline.slotID = 2
        timeline.physical_num = 1

        pulldown = d.create.Pulldown("Picture")

        timecode = d.create.Timecode(98, 216000, 60)
        timecode.media_kind = "Timecode"

        pulldown.segment = timecode
        pulldown.length = 39

        pulldown.kind = "TwentyFourToSixtyPD"
        pulldown.direction = "TapeToFilmSpeed"
        pulldown.phase = 0

        print(pulldown.kind)
        print(pulldown.direction)
        print(pulldown.phase)

        timeline.segment = pulldown

        source_mob.insert_slot(1, timeline)

        f.save()
        f.save(output_xml)
        f.close()

    def test_external_mob(self):
        output_aaf = os.path.join(sandbox, 'external_essence_create.aaf')
        output_xml = os.path.join(sandbox, 'external_essence_create.xml')
        if os.path.exists(output_aaf):
            os.remove(output_aaf)
        f = aaf.open(output_aaf, 'rw')

        header = f.header
        d = f.dictionary

        master_mob = d.create.MasterMob("external_mob")
        f.storage.add_mob(master_mob)

        media_kind = "picture"

        phys_source_mob = d.create.SourceMob()
        phys_source_mob.name = "IMG.PHYS"
        desc = d.create.CDCIDescriptor()

        for item in desc.classdef().propertydefs():
            print('  ', item.name, item.optional)

        loc = d.create.NetworkLocator()

        loc_path = "file:///Giraffe/Avid%20MediaFiles/MXF/1/IMG_4943.JPG1378511522A699C.mxf"
        loc.path = loc_path

        assert loc.path == loc_path

        desc.append_locator(loc)
        desc.sample_rate = "23976/1000"
        desc.container_format = "AAFKLV"
        print(desc.container_format)
        desc.compression = "Avid_DNxHD_Legacy"
        print(desc.compression)
        width,height = 1280, 720

        desc.stored_view = (width, height)
        desc.sampled_view = (width, height, 0, 0)
        desc.display_view = (width, height, 0, 0)
        desc.aspect_ratio = "16/9"

        desc.line_map = (26,0)
        desc.color_range = 255
        desc.horizontal_subsampling = 2
        desc.vertical_subsampling = 1
        desc.component_width = 8

        desc.image_alignment = 8192


        phys_source_mob.essence_descriptor = desc
        f.storage.add_mob(phys_source_mob)

        phys_source_mob.add_nil_ref(1, 39, 'picture',"23976/1000" )

        master_mob.add_master_slot(media_kind, 1, phys_source_mob, 1)


        f.save()
        f.save(output_xml)
        f.close()


    def test_tape(self):
        output_aaf = os.path.join(sandbox, 'tape_essence_create.aaf')
        output_xml = os.path.join(sandbox, 'tape_essence_create.xml')

        if os.path.exists(output_aaf):
            os.remove(output_aaf)
        f = aaf.open(output_aaf, 'rw')

        header = f.header
        d = f.dictionary

        tape_name = "tape_01"

        master_mob = d.create.MasterMob("clip1")
        f.storage.add_mob(master_mob)

        source_mob = d.create.SourceMob()
        source_mob.name = tape_name
        tape_desc = d.create.TapeDescriptor()
        source_mob.essence_descriptor = tape_desc
        f.storage.add_mob(source_mob)

        # Now add Video and Audio Tracks
        for track in range(3):

            # Create A New Slot
            timeline = d.create.TimelineMobSlot()
            timeline.editrate = "23976/1000"
            timeline.origin = 0
            timeline.slotID = track + 1

            # set the audio channel, zero if video
            timeline.physical_num = track

            media_kind = "sound"
            if track == 0:
                media_kind = 'picture'

            # Create a clip NULL clip
            clip = d.create.SourceClip(length= 100, media_kind=media_kind)

            # Set the Segemnt to the clip
            timeline.segment = clip

            # Add the timeline to the Source Mob
            source_mob.insert_slot(track, timeline)

            # Add the SourceMob slot to the Master Mob Slot
            master_mob.add_master_slot(media_kind, track+1, source_mob, track+1)

        f.save()
        f.save(output_xml)
        f.close()


    def test_create_comp(self):

        output_aaf = os.path.join(sandbox, 'comp_essence_create.aaf')
        output_xml = os.path.join(sandbox, 'copm_essence_create.xml')
        if os.path.exists(output_aaf):
            os.remove(output_aaf)
        f = aaf.open(output_aaf, 'rw')

        header = f.header
        storage = f.storage
        d = f.dictionary

        picture_mastermob1 = d.create.MasterMob("Picture Mob 1")
        picture_mastermob2 = d.create.MasterMob("Picture Mob 2")
        storage.add_mob(picture_mastermob1)
        storage.add_mob(picture_mastermob2)

        sound_mastermob1 = d.create.MasterMob("sound Mob 1")
        sound_mastermob2 = d.create.MasterMob("sound Mob 2")
        storage.add_mob(sound_mastermob1)
        storage.add_mob(sound_mastermob2)


        comp = d.create.CompositionMob("Comp Example")
        storage.add_mob(comp)

        print(comp.mobID)

        audio_sequence = d.create.Sequence("Sound")
        video_sequence = d.create.Sequence("Picture")

        edit_rate = "25/1"
        video_slot_num = 1
        video_slot_name = "Video Timeline"

        timeline_slot = comp.append_new_timeline_slot(edit_rate, video_sequence)


        rate = "25/1"
        picture_essence = picture_mastermob1.create_essence(1,
                                                             media_kind= "picture",
                                                             codec_name="JPEG",
                                                             edit_rate = rate,
                                                             sample_rate = rate,
                                                             compress=True)

        slot = list(picture_mastermob1.slots())[0]

        print(slot.media_kind, slot.slotID)

        slot.segment.length = 100
        print(slot.segment.length)

        #clip = d.create.SourceClip(picture_mastermob1,slot.slotID, 10, 0 )
        print("****", slot.slotID)
        clip = picture_mastermob1.create_clip(slot.slotID, 10, 0)
        clip2 = picture_mastermob1.create_clip(slot.slotID)
        clip3 = picture_mastermob1.create_clip(slot.slotID, 20, 10)
        clip4 = picture_mastermob1.create_clip()
        clip5 = picture_mastermob1.create_clip(length = 60)
        video_sequence.append(clip)
        video_sequence.append(clip2)
        video_sequence.append(clip3)
        video_sequence.append(clip4)
        video_sequence.append(clip5)

        f.save()
        f.save(output_xml)
        f.close()


if __name__ == '__main__':
    unittest.main()
