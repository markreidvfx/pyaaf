"""
dumps all the essence data in a aaf file to the current working directory,
trys to put a extension of the file but currently doesn't do every codec format
"""

import aaf
import aaf.essence
import os
from optparse import OptionParser

parser = OptionParser()
(options, args) = parser.parse_args()

if not args:
    parser.error("not enough argements")

path = args[0]

f = aaf.open(path)
basename = os.path.basename(path)
name,ext = os.path.splitext(basename)
dest_dir = os.path.join(os.path.dirname(path), "%s_essence_data" % name)
if not os.path.exists(dest_dir):
    os.makedirs(dest_dir)


for i, essence in enumerate(f.storage.essence_data()):
    mob = essence.source_mob

    # essence_descriptor can tell you about the type of essence data
    essence_descriptor = mob.essence_descriptor

    # codec definition will tell you about the codec of the encoded data
    codec_def = essence_descriptor['CodecDefinition'].value

    codec_def_name = None
    if codec_def:
        codec_def_name = codec_def.name

    # find a suitable extenstion for output file current only pcm,and dnxhd
    if codec_def_name == "PCM Codec":
        sample_rate = essence_descriptor['SampleRate'].value
        channels = essence_descriptor['Channels'].value
        ext = '_%i_%i.pcm' % (sample_rate, channels)

    elif codec_def_name == "AAF DNxHD Codec" or isinstance(essence_descriptor, aaf.essence.CDCIDescriptor):
        ext = '.dnxhd'
    else:
        ext = ''

    outpuf_file_name = os.path.join(dest_dir, "stream_%d%s" % (i, ext))
    output_file = open(outpuf_file_name, 'w')

    print "dumping data to", outpuf_file_name

    use_byte_array = True
    if use_byte_array:
        data = bytearray(2048)
        while True:
            bytes_read = essence.readinto(data)
            if not bytes_read:
                break
            output_file.write(data[:bytes_read])
    else:
        while True:
            data = essence.read(2048)
            if not data:
                break
            output_file.write(data)
    output_file.close()
