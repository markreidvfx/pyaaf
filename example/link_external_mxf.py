
import subprocess
import json
import fractions
import pprint
import sys
import aaf

# requres ffmpeg version > 2.5
FFPROBE_EXEC = "ffprobe"

def probe(path):

    cmd = [FFPROBE_EXEC, '-of','json','-show_format','-show_streams', path]
    print subprocess.list2cmdline(cmd)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout,stderr = p.communicate()
    if p.returncode != 0:
        raise subprocess.CalledProcessError(p.returncode, subprocess.list2cmdline(cmd), stderr)

    return json.loads(stdout)


mxf_file = sys.argv[1]
aaf_file = sys.argv[2]

f = aaf.open(aaf_file, 'w')


data = probe(mxf_file)
pprint.pprint(data)

# opatom mxf files should only have single streams
format = data['format']
metadata = format['tags']
stream = data['streams'][0]

stream_metadata = stream['tags']

material_package_name = metadata['material_package_name']
material_package_umid = metadata['material_package_umid']

file_package_umid = stream_metadata['file_package_umid']
file_package_name = stream_metadata['file_package_name']

reel_umid = stream_metadata['reel_umid']
reel_name = stream_metadata['reel_name']

codec_type = stream['codec_type']

rate = fractions.Fraction(stream['avg_frame_rate'])
duration = stream['duration_ts'] #int(float(stream['duration']) * float(rate))

print "file package umid = ", file_package_umid
print "duration =", duration

if codec_type == 'video':
    media_kind = "picture"
    width = int(stream['width'])
    height = int(stream['height'])

    descriptor = f.create.CDCIDescriptor()

    descriptor['DisplayXOffset'].value = 0
    descriptor['DisplayYOffset'].value = 0
    descriptor['DisplayHeight'].value = height
    descriptor['DisplayWidth'].value = width
    descriptor['SampledXOffset'].value = 0
    descriptor['SampledYOffset'].value = 0
    descriptor['SampledWidth'].value = width
    descriptor['SampledHeight'].value = height
    descriptor['StoredWidth'].value = width
    descriptor['StoredHeight'].value = height

    descriptor['ImageAspectRatio'].value = fractions.Fraction(width, height)
    descriptor['SampleRate'].value = rate
    descriptor['HorizontalSubsampling'].value = 2

elif codec_type == 'audio':
    raise Exception("Audio not supported yet")
else:
    raise Exception("Unknown media kind %s" % codec_type)

descriptor['Length'].value = duration



reel_mob = f.create.SourceMob(file_package_name)
reel_mob.umid = reel_umid
reel_mob.essence_descriptor = f.create.ImportDescriptor()


source_clip = f.create.SourceClip('picture', duration)
sequence = f.create.Sequence("picture")
sequence.append(source_clip)
reel_mob.append_new_timeline_slot(rate, sequence, 1)

timecode = f.create.Timecode(duration, 86400, 24)
sequence = f.create.Sequence("LegacyTimecode")
sequence.append(timecode)
reel_mob.append_new_timeline_slot(rate, sequence, 2)
source_clip = reel_mob.create_clip(1)

file_package_mob = f.create.SourceMob(file_package_name)
file_package_mob.umid = file_package_umid
file_package_mob.essence_descriptor = descriptor

sequence = f.create.Sequence("picture")
sequence.append(source_clip)
slot = file_package_mob.append_new_timeline_slot(rate, sequence, 1)
#slot = file_package_mob.add_nil_ref(1, duration, media_kind, rate)
#print slot.segment.all_keys()

source_clip = file_package_mob.create_clip(1)

mastermob = f.create.MasterMob(material_package_name)
#mastermob.umid = material_package_umid
mastermob.append_new_timeline_slot(rate, source_clip, 1)

f.storage.add_mob(reel_mob)
f.storage.add_mob(file_package_mob)
f.storage.add_mob(mastermob)


f.save()