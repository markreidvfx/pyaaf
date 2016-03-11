from __future__ import print_function
import unittest
import traceback
import os
import subprocess
import time

from struct import unpack
from fractions import Fraction
import aaf

FFMPEG_EXEC='ffmpeg'

sandbox = os.path.join(os.path.dirname(os.path.abspath(__file__)),'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

UNC_PAL_FRAME_SIZE = 720*576*2
UNC_NTSC_FRAME_SIZE = 720*480*2

import array

DNxHD_Formats =[
{ "size":"1920x1080p", "bitrate":175, "pix_fmt":"yuv422p10", "frame_rate":"24000/1001"},
{ "size":"1920x1080p", "bitrate":185, "pix_fmt":"yuv422p10", "frame_rate":"25/1"},
{ "size":"1920x1080p", "bitrate":365, "pix_fmt":"yuv422p10", "frame_rate":"50/1"},
{ "size":"1920x1080p", "bitrate":440, "pix_fmt":"yuv422p10", "frame_rate":"60000/1001"},
{ "size":"1920x1080p", "bitrate":115, "pix_fmt":"yuv422p",   "frame_rate":"24000/1001"},
{ "size":"1920x1080p", "bitrate":120, "pix_fmt":"yuv422p",   "frame_rate":"25/1"},
{ "size":"1920x1080p", "bitrate":145, "pix_fmt":"yuv422p",   "frame_rate":"30000/1001"},
{ "size":"1920x1080p", "bitrate":240, "pix_fmt":"yuv422p",   "frame_rate":"50/1"},
{ "size":"1920x1080p", "bitrate":290, "pix_fmt":"yuv422p",   "frame_rate":"60000/1001"},
{ "size":"1920x1080p", "bitrate":175, "pix_fmt":"yuv422p",   "frame_rate":"24000/1001"},
{ "size":"1920x1080p", "bitrate":185, "pix_fmt":"yuv422p",   "frame_rate":"25/1"},
{ "size":"1920x1080p", "bitrate":220, "pix_fmt":"yuv422p",   "frame_rate":"30000/1001"},
{ "size":"1920x1080p", "bitrate":365, "pix_fmt":"yuv422p",   "frame_rate":"50/1"},
{ "size":"1920x1080p", "bitrate":440, "pix_fmt":"yuv422p",   "frame_rate":"60000/1001"},
{ "size":"1920x1080i", "bitrate":185, "pix_fmt":"yuv422p10", "frame_rate":"25/1"},
{ "size":"1920x1080i", "bitrate":220, "pix_fmt":"yuv422p10", "frame_rate":"30000/1001"},
{ "size":"1920x1080i", "bitrate":120, "pix_fmt":"yuv422p",   "frame_rate":"25/1"},
{ "size":"1920x1080i", "bitrate":145, "pix_fmt":"yuv422p",   "frame_rate":"30000/1001"},
{ "size":"1920x1080i", "bitrate":185, "pix_fmt":"yuv422p",   "frame_rate":"25/1"},
{ "size":"1920x1080i", "bitrate":220, "pix_fmt":"yuv422p",   "frame_rate":"30000/1001"},
{ "size":"1280x720p",  "bitrate":90,  "pix_fmt":"yuv422p10", "frame_rate":"24000/1001"},
{ "size":"1280x720p",  "bitrate":90,  "pix_fmt":"yuv422p10", "frame_rate":"25/1"},
{ "size":"1280x720p",  "bitrate":180, "pix_fmt":"yuv422p10", "frame_rate":"50/1"},
{ "size":"1280x720p",  "bitrate":220, "pix_fmt":"yuv422p10", "frame_rate":"60000/1001"},
{ "size":"1280x720p",  "bitrate":90,  "pix_fmt":"yuv422p",   "frame_rate":"24000/1001"},
{ "size":"1280x720p",  "bitrate":90,  "pix_fmt":"yuv422p",   "frame_rate":"25/1"},
{ "size":"1280x720p",  "bitrate":110, "pix_fmt":"yuv422p",   "frame_rate":"30000/1001"},
{ "size":"1280x720p",  "bitrate":180, "pix_fmt":"yuv422p",   "frame_rate":"50/1"},
{ "size":"1280x720p",  "bitrate":220, "pix_fmt":"yuv422p",   "frame_rate":"60000/1001"},
{ "size":"1280x720p",  "bitrate":60,  "pix_fmt":"yuv422p",   "frame_rate":"24000/1001"},
{ "size":"1280x720p",  "bitrate":60,  "pix_fmt":"yuv422p",   "frame_rate":"25/1"},
{ "size":"1280x720p",  "bitrate":75,  "pix_fmt":"yuv422p",   "frame_rate":"30000/1001"},
{ "size":"1280x720p",  "bitrate":120, "pix_fmt":"yuv422p",   "frame_rate":"50/1"},
{ "size":"1280x720p",  "bitrate":145, "pix_fmt":"yuv422p",   "frame_rate":"60000/1001"},
{ "size":"1920x1080p", "bitrate":36,  "pix_fmt":"yuv422p",   "frame_rate":"24000/1001"},
{ "size":"1920x1080p", "bitrate":36,  "pix_fmt":"yuv422p",   "frame_rate":"25/1"},
{ "size":"1920x1080p", "bitrate":45,  "pix_fmt":"yuv422p",   "frame_rate":"30000/1001"},
{ "size":"1920x1080p", "bitrate":75,  "pix_fmt":"yuv422p",   "frame_rate":"50/1"},
{ "size":"1920x1080p", "bitrate":90,  "pix_fmt":"yuv422p",   "frame_rate":"60000/1001"}]


#generate auid
#ffmpeg -f lavfi -i aevalsrc="sin(440*2*PI*t)::s=4800:d=5,aconvert=s16:stereo:packed" out.wav
#stero
#ffplay -f lavfi -i "aevalsrc=sin(420*2*PI*t):cos(430*2*PI*t)::s=4800"

#raw output
#ffmpeg -i <input> -f s16le -acodec pcm_s16le output.raw

def encode_dnxhd(size, bit_rate, pix_fmt, frame_rate, frames, name, iterlaced=False):

    outfile = os.path.join(sandbox, "%s.dnxhd" % name )
    cmd = [FFMPEG_EXEC, '-y', '-f', 'lavfi', '-i', 'testsrc=size=%dx%d:rate=%s' % (size[0],size[1], frame_rate), '-frames:v', str(frames)]
    cmd.extend(['-vcodec', 'dnxhd','-pix_fmt', pix_fmt, '-vb', '%dM' % bit_rate ])

    if iterlaced:
        cmd.extend(['-flags', '+ildct+ilme' ])

    cmd.extend([outfile])

    print(subprocess.list2cmdline(cmd))
    p = subprocess.Popen(cmd, stdout = subprocess.PIPE,stderr = subprocess.PIPE)

    stdout,stderr = p.communicate()
    print(stderr)
    if p.returncode < 0:

        return Exception("error encoding footage")
    return outfile


def generate_pcm_audio_mono(name, sample_rate = 48000, duration = 2, format='pcm'):

    outfile = os.path.join(sandbox, '%s.%s' % (name, format))

    #cmd = ['ffmpeg','-y', '-f', 'lavfi', '-i', 'aevalsrc=sin(420*2*PI*t):cos(430*2*PI*t)::s=48000:d=10']

    #mono
    cmd = [FFMPEG_EXEC,'-y', '-f', 'lavfi', '-i', 'aevalsrc=sin(420*2*PI*t)::s=%d:d=%f' % (sample_rate, duration)]

    if format == 'pcm':

        cmd.extend([ '-f','s16le', '-acodec', 'pcm_s16le'])

    cmd.extend([outfile])

    print(subprocess.list2cmdline(cmd))
    p = subprocess.Popen(cmd, stdout = subprocess.PIPE,stderr = subprocess.PIPE)
    stdout,stderr = p.communicate()
    print(stderr)
    if p.returncode < 0:
        return Exception("error encoding footage")
    return outfile

def generate_pcm_audio_stereo(name, sample_rate = 48000, duration = 2):

    outfile = os.path.join(sandbox, '%s.pcm' % name)

    cmd = [FFMPEG_EXEC,'-y', '-f', 'lavfi', '-i', 'aevalsrc=sin(420*2*PI*t):cos(430*2*PI*t)::s=%d:d=%f'% ( sample_rate, duration)]

    #mono
    #cmd = ['ffmpeg','-y', '-f', 'lavfi', '-i', 'aevalsrc=sin(420*2*PI*t)::s=48000:d=10']

    cmd.extend([ '-f','s16le', '-acodec', 'pcm_s16le'])

    cmd.extend([outfile])

    print(subprocess.list2cmdline(cmd))
    p = subprocess.Popen(cmd, stdout = subprocess.PIPE,stderr = subprocess.PIPE)
    stdout,stderr = p.communicate()
    print(stderr)
    if p.returncode < 0:
        return Exception("error encoding footage")
    return outfile

class TestImport(unittest.TestCase):


    def test_dnxhd_export(self):

        """
        width, height = unpack(">24xhh", s[:28])
        cid = unpack(">40xi", s[:44])

        ffmpeg -i <input_file> -vcodec dnxhd -b <bitrate> -an output.dnxhd

        # haven't tried this
        -pix_fmt yuv422p10le -vb 175M or 185M or 365M or 440M for 10 bit

        componentWidths", "pix_fmt8,10,16
        horizontalSubsampling:
        1 = 4:4:4
        2 = 4:2:2 -pix_fmt yuv422p
        4 = 4:1:1
        framerates:
            60/1
            5994/1000
            50/1
            30000/1001
            25/1
            24/1
            23976/1000

        # 1920x1080p
        Flavour_VC3_1235 = DNX_220X_1080p 220M 10bit 917504 bytes per sample
        Flavour_VC3_1237 = DNX_145_1080p  145M 8bit  606208 bytes per sample
        Flavour_VC3_1238 = DNX_220_1080p  220M 8bit  917504 bytes per sample

        # 1920x1080i
        Flavour_VC3_1241 = DNX_220X_1080i 220M 10bit 917504 bytes per sample
        Flavour_VC3_1242 = DNX_145_1080i 145M 8bit 606208 bytes per sample
        Flavour_VC3_1243 = DNX_220_1080i 220M 8bit  917504 bytes per sample

        # 1440x1080i
        Flavour_VC3_1244 = DNX_145_1440_1080i 145M 8bit 606208 bytes per sample

        # 1280x720p
        Flavour_VC3_1250 = DNX_220X_720p  220M 10bit 458752 bytes per sample
        Flavour_VC3_1251 = DNX_220_720p  220M 8bit 458752 bytes per sample
        Flavour_VC3_1252 = DNX_145_720p  145M 8bit 303104 bytes per sample

        # 1920x1080p
        Flavour_VC3_1253 = DNX_36_1080p 36M 8bit 188416 bytes per sample

        # 1920x1080i
        Flavour_VC3_1254 = DNX_50_1080i 50M 8bit 131072 bytes per sample note: might be wrong

        """
        output_aaf = os.path.join(sandbox, 'dnxhd_export.aaf')
        output_xml = os.path.join(sandbox, 'dnxhd_export.xml')

        f= aaf.open(output_aaf, 'w')


        header = f.header
        d = f.dictionary

        count = 0
        #time.sleep(10)
        for num,item in enumerate(DNxHD_Formats):

            if count > 1:
                pass
                #break

            frame_rate = item['frame_rate']
            pix_fmt = item['pix_fmt']
            bitrate = item['bitrate']
            print(num, item)

            nb_frames = 10

            width, height_inter = item['size'].split('x')
            interlaced = False
            if height_inter[-1] == 'i':
                interlaced = True

            if interlaced:
                continue


            width = int(width)
            height = int(height_inter[:-1])

            size = (width,height)

            #print width, height, inter, pix_fmt, bitrate, frame_rate

            name = "%s_%dM_%s_%0.3ffps" % (item['size'], bitrate, pix_fmt, float(Fraction(frame_rate)))

            print(name)

            mastermob = d.create.MasterMob(name)
            f.storage.add_mob(mastermob)

            mastermob.append_comment(u"Encoding Format", name)

            essence = mastermob.create_essence(1,
                                               "picture",
                                               "DNxHD",
                                               frame_rate,
                                               frame_rate,
                                               compress = False,
                                               )

            # will do this by default in create_essence if codec is dnxhd

            if interlaced:
                essence.codec_flavour = "Flavour_VC3_1242"
            else:
                essence.codec_flavour = "Flavour_VC3_1253"

            print("!!", essence.codec_name)

            dnx_path = encode_dnxhd(size, bitrate, pix_fmt, frame_rate, nb_frames, name, interlaced)

            dnx = open(dnx_path, 'rb')
            dnx_header = dnx.read(640)


            width, height = unpack(">24xhh", dnx_header[:28])
            cid = unpack(">40xi", dnx_header[:44])[0]
            print("header:", width, height ,'compression id:',cid)
            essence.codec_flavour = "Flavour_VC3_%d" % cid
            dnx.close()

            dnx = open(dnx_path, 'rb')
            print("getting read size")
            readsize = essence.max_sample_size

            print("readsize =",readsize)
            count = 0
            while True:
                print("count", count)
                data = dnx.read(readsize)
                if not data:
                    break
                essence.write(data, 1)
                count += 1
            essence.complete_write()

            codec_name,codeID = essence.codec_name, essence.codecID

            #add audio tracks

            rate = 48000
            sampe_rate = "%d/1" % rate

            duration = nb_frames / float(Fraction(frame_rate))
            audio_essences = []

            for i in range(2):

                essence = mastermob.create_essence(i + 2,
                                           "sound",
                                           "PCM",
                                           sampe_rate,
                                           sampe_rate,
                                           compress = False,
                                           )
                essence.codec_flavour = "Flavour_None"
                format = essence.get_emptyfileformat()

                format['AudioSampleBits'] = 16
                format['NumChannels'] = 1

                essence.set_fileformat(format)

                audio_essences.append(essence)

            pcm_file = generate_pcm_audio_stereo(name, rate, duration)
            pcm = open(pcm_file, 'rb')

            readsize = 2

            data = None

            print("writing audio data")


            count = 0
            while True:
                for essence in audio_essences:
                    data = pcm.read(readsize)

                    if not data:
                        break

                    if len(data) != readsize:
                        break
                    #rint "read", len(data)
                    essence.write(data)
                if not data:
                    break

                # emergency break
                if count > 48000*10:
                    pass
                    break

                count += 1

            for essence in audio_essences:
                essence.complete_write()


            count += 1

        print("wrote", count/2, "audio samples")

        f.save()
        print("save")
        f.save(output_xml)
        f.close()

        print("reading")
        # test reading
        f = aaf.open(output_aaf)

        storage = f.storage
        #time.sleep(10)
        for mob in storage.master_mobs():
            print("Opening essence", mob.name)
            essence = mob.open_essence(1)
            c= 0
            while True:
                print("reading data")
                data = essence.read()
                if not data:
                    break
                print("read", len(data), 'bytes')
                c += 1

            assert c == nb_frames


        for essence in f.storage.essence_data():

            mob = essence.source_mob
            #print mob

            while True:
                data = essence.read(1024)

                if not data:
                    break

                position = essence.position
                size = essence.size
                #print mob, len(data), position, size


        f.close()

    def test_audio_mono(self):
        output_aaf = os.path.join(sandbox, 'mono_audio_export.aaf')
        output_xml = os.path.join(sandbox, 'mono_audio_export.xml')

        f= aaf.open(output_aaf, 'w')


        header = f.header
        d = f.dictionary

        count = 0

        name = "mono_audio_export"

        mastermob = d.create.MasterMob(name)
        f.storage.add_mob(mastermob)

        rate = 48000

        sampe_rate = "%d/1" % rate

        essence = mastermob.create_essence(1,
                                           "sound",
                                           "PCM",
                                           sampe_rate,
                                           sampe_rate,
                                           compress = False,
                                           #fileformat = 'RIFFWAVE'
                                           )
        essence.codec_flavour = "Flavour_None"
        format = essence.get_emptyfileformat()

        format['AudioSampleBits'] = 16
        format['NumChannels'] = 1


        essence.set_fileformat(format)

        del format

        pcm_file = generate_pcm_audio_mono(name, rate, 2)
        pcm = open(pcm_file, 'rb')

        readsize= essence.max_sample_size

        while True:
            chunk = pcm.read(readsize)
            if not chunk:
                break
            if len(chunk) != readsize:
                break
            essence.write(chunk)


        essence.complete_write()
        f.save()
        f.save(output_xml)

    def test_audio_stereo(self):
        output_aaf = os.path.join(sandbox, 'stereo_audio_export.aaf')
        output_xml = os.path.join(sandbox, 'stereo_audio_export.xml')

        f= aaf.open(output_aaf, 'w')

        header = f.header
        d = f.dictionary

        count = 0

        name = "stereo_audio_export"

        mastermob = d.create.MasterMob(name)
        f.storage.add_mob(mastermob)

        rate = 48000

        sampe_rate = "%d/1" % rate

        essence_left = mastermob.create_essence(1,
                                           "sound",
                                           "PCM",
                                           sampe_rate,
                                           sampe_rate,
                                           compress = False,
                                           #fileformat = 'RIFFWAVE'
                                           )
        essence_right = mastermob.create_essence(2,
                                           "sound",
                                           "PCM",
                                           sampe_rate,
                                           sampe_rate,
                                           compress = False,
                                           )
        essence_left.codec_flavour = "Flavour_None"
        essence_right.codec_flavour = "Flavour_None"
        format = essence_left.get_emptyfileformat()

        format['AudioSampleBits'] = 16
        format['NumChannels'] = 1
        essence_left.set_fileformat(format)

        format = essence_right.get_emptyfileformat()

        format['AudioSampleBits'] = 16
        format['NumChannels'] = 1
        essence_right.set_fileformat(format)

        pcm_file = generate_pcm_audio_stereo(name, rate, 2)

        # readsize should be 2 UInt16_t or unsigned short is 2 bytes
        readsize= essence_left.max_sample_size
        #readsize = 1000
        print("max",readsize)

        pcm = open(pcm_file, 'rb')


        while True:
            chunk = pcm.read(readsize)
            chunk2 = pcm.read(readsize)

            if not chunk or not chunk2:
                break

            if len(chunk) != readsize or len(chunk2) != readsize:
                break

            essence_left.write(chunk)
            essence_right.write(chunk2)

        essence_left.complete_write()
        essence_right.complete_write()
        f.save()
        f.save(output_xml)

    def test_mob_import_method(self):
        output_aaf = os.path.join(sandbox, 'mob_import_essence.aaf')
        output_xml = os.path.join(sandbox, 'mob_import_essence.xml')

        f= aaf.open(output_aaf, 'w')

        header = f.header
        d = f.dictionary

        count = 0

        name = "mob_import_essence"

        mastermob = d.create.MasterMob(name)
        f.storage.add_mob(mastermob)


        size = (1920, 1080)
        bitrate = 36
        pix_fmt = "yuv422p"
        frame_rate = "24000/1001"
        nb_frames = 20

        video_path = encode_dnxhd(size, bitrate, pix_fmt, frame_rate, nb_frames, name, False)

        mastermob.import_video_essence(video_path, frame_rate)


        duration = nb_frames / float(Fraction(frame_rate))
        sample_rate = 48000
        pcm_file_path = generate_pcm_audio_stereo(name, sample_rate, duration)

        mastermob.import_audio_essence(pcm_file_path, 2, sample_rate)

        pcm_file_path = generate_pcm_audio_mono(name, sample_rate, duration)

        mastermob.import_audio_essence(pcm_file_path, 1, sample_rate)

        f.save()
        f.save(output_xml)

if __name__ == '__main__':
    unittest.main()
