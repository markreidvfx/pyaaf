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


for i, essence in enumerate(f.storage.essence_data()):
    mob = essence.source_mob

    # essence_descriptor can tell you about the type of essence data
    essence_descriptor = mob.essence_descriptor

    # codec definition will tell you about the codec of the encoded data
    codec_def = essence_descriptor['CodecDefinition'].value

    # find a suitable extenstion for output file current only pcm,and dnxhd
    if codec_def.name == "PCM Codec":
        sample_rate = essence_descriptor['SampleRate'].value
        channels = essence_descriptor['Channels'].value
        ext = '_%i_%i.pcm' % (sample_rate, channels)

    elif codec_def.name == "AAF DNxHD Codec":
        ext = '.dnxhd'
    else:
        ext = ''

    outpuf_file_name = str(mob.mobID).replace("urn:smpte:umid:", '') + ext
    output_file = open(outpuf_file_name, 'w')

    print "dumping data for source mob", mob.mobID,codec_def.name, essence_descriptor, outpuf_file_name

    while True:
        data = essence.read(1024)
        if not data:
            break
        output_file.write(data)
    output_file.close()
