import unittest
import traceback
import os
import subprocess

from fractions import Fraction
import aaf


sandbox = os.path.join(os.path.dirname(os.path.abspath(__file__)),'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

UNC_PAL_FRAME_SIZE = 720*576*2
UNC_NTSC_FRAME_SIZE = 720*480*2 


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

def encode_dnxhd(size, bit_rate, pix_fmt, frame_rate, frames, name, iterlaced=False):
    
    outfile = os.path.join(sandbox, "%s.dnxhd" % name )
    cmd = ['ffmpeg', '-y', '-f', 'lavfi', '-i', 'testsrc=size=%dx%d:rate=%s' % (size[0],size[1], frame_rate), '-frames:v', str(frames)]
    cmd.extend(['-vcodec', 'dnxhd','-pix_fmt', pix_fmt, '-vb', '%dM' % bit_rate ])
    
    if iterlaced:
        cmd.extend(['-flags', '+ildct+ilme' ])
    
    cmd.extend([outfile])
    
    print subprocess.list2cmdline(cmd)
    p = subprocess.Popen(cmd, stdout = subprocess.PIPE,stderr = subprocess.PIPE)
    
    stdout,stderr = p.communicate()
    
    if p.returncode < 0:
        print stderr
        return Exception("error encoding footage")
    return outfile

class TestFile(unittest.TestCase):
    

    def test_export_ffmpeg(self):
        """
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
        Flavour_VC3_1235 = DNX_220X_1080p 220M 10bit
        Flavour_VC3_1237 = DNX_145_1080p  145M 8bit 
        Flavour_VC3_1238 = DNX_220_1080p  220M 8bit 
        
        # 1920x1080i
        Flavour_VC3_1241 = DNX_220X_1080i 220M 10bit
        Flavour_VC3_1242 = DNX_145_1080i 145M 8bit 
        Flavour_VC3_1243 = DNX_220_1080i 220M 8bit 
        
        # 1440x1080i
        Flavour_VC3_1244 = DNX_145_1440_1080i 145M 8bit 
        
        # 1280x720p
        Flavour_VC3_1250 = DNX_220X_720p  220M 10bit
        Flavour_VC3_1251 = DNX_220_720p  220M 8bit
        Flavour_VC3_1252 = DNX_145_720p  145M 8bit
        
        # 1920x1080p
        Flavour_VC3_1253 = DNX_36_1080p 36M 8bit 
        
        # 1920x1080i
        Flavour_VC3_1254 = DNX_50_1080i 50M 8bit

        """
        output_aaf = os.path.join(sandbox, 'ffmpeg_export.aaf')
        output_xml = os.path.join(sandbox, 'ffmpeg_export.xml')
                
        f= aaf.open(output_aaf, 'rw')
        
        
        header = f.header()
        d = header.dictionary()
        
        
        
        for item in DNxHD_Formats:
            frame_rate = item['frame_rate']
            pix_fmt = item['pix_fmt']
            bitrate = item['bitrate']
            
            
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
            
            print name
            
        
        #raise Exception()
        
        
        #for name, size, frame_rate,bit_rate in [["720p90", (1280,720), "23976/1000", 90],
        #                                        ["720p175M50", (1280,720), "50/1", 120],
        #                                        ["1080p115", (1920,1080), "23976/1000", 115],]:
        
            mastermob = d.create.MasterMob(name)
            header.append(mastermob)
            
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

            
            dnx_path = encode_dnxhd(size, bitrate, pix_fmt, frame_rate, 10, name, interlaced)
    
            dnx = open(dnx_path)
            
            readsize = essence.max_sample_size(d.lookup_datadef('picture'))
            
            print "readsize =",readsize
            while True:
                data = dnx.read(readsize)
                if not data:
                    break
                essence.write(data, 1)
            essence.complete_write()
        
        f.save()
        f.save(output_xml)

    
if __name__ == '__main__':
    unittest.main()