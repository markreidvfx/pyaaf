#! /usr/bin/python

#this will take every mxf file in a folder and make ONE AAF File containing all clips and a sequence of all clips on the desktop
import subprocess
import json
import fractions
import pprint
import sys
import urllib
import aaf
from aaf import util,fraction_util,base,define,property,dictionary,iterator,mob,component,essence #all these are here to build a self contained

import os
from os import listdir
from optparse import OptionParser #to get options in command line interface
import uuid
import time
## dd_mm_yyyy format
currentdate=time.strftime("%d_%m_%Y")
print "date is "+currentdate




parser = OptionParser(prog='multiaaf',usage='multiaaf [OPTIONS][/path/to/source/mxf(s)] [name_of_AAF_to_be_written_on_desktop]\nREQUIRES ffprobe and avidmxfinfo in usr/local/bin')
parser.add_option("-r", "--videorate",dest="video_rate",type="int",default=25,help="video frame rate of sequence and files.The default is %default")

(options, args) = parser.parse_args()
print "Video Framerate is "+str(options.video_rate) +" fps"


#if not args:
#parser.error("ERROR: use like this\n multiaaf [/path/to/source/folder] [name_of_aaf_on_desktop]\nCheers!")
video_rate=options.video_rate #this could be defined from first mxf maybe?At the moment this is the default cos i made this in the UK


try:
    folderpath = args[0]
except:
    parser.error('no SOURCE folder or file defined mate!\ntry again\n\n')

try:
    outputname = args[1]
except:
    parser.error('no OUTPUT AAF named mate!\ntry again\n\n')


userhome = os.path.expanduser('~')
mydesktop = userhome + '/Desktop/'

output_text_file = open(os.path.join(mydesktop, outputname+'_details.txt'), "w")
print >>output_text_file, "----DETAILS FOR",outputname,"ON",currentdate,"----\n"
print >>output_text_file, "framerate chosen",video_rate

def frames_to_timecode(frames):
    return '{0:02d}:{1:02d}:{2:02d}:{3:02d}'.format(frames / (3600*video_rate),
                                                    frames / (60*video_rate) % 60,
                                                    frames / video_rate % 60,
                                                    frames % video_rate)

output_aaf = os.path.join(mydesktop, outputname+'.aaf')
if os.path.exists(output_aaf):
    os.remove(output_aaf)

#if not os.path.exists(outputpath):
# os.makedirs(outputpath)

#seqname=folderpath.split("/")[-1]

FFPROBE_EXEC = "/usr/local/bin/ffprobe"
AVID_MXF_INFO_EXEC = "/usr/local/bin/avidmxfinfo"

def probe(path):

    cmd = [FFPROBE_EXEC, '-of','json','-show_format','-show_streams', path]
    #print subprocess.list2cmdline(cmd)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout,stderr = p.communicate()
    if p.returncode != 0:
        raise subprocess.CalledProcessError(p.returncode, subprocess.list2cmdline(cmd), stderr)

    return json.loads(stdout)

def chunks(l, n):
    """ Yield successive n-sized chunks from l.
        """
    for i in xrange(0, len(l), n):
        yield l[i:i+n]

def parse_umid(line):

    line = line.split(' = ')[-1]
    umid =  "urn:smpte:umid:" + '.'.join([item for item in chunks(line, 8) ])

    mob_id = aaf.util.MobID(umid)
    mob_id.material = line[-32:]

    return mob_id

def mxfinfo(path):
    cmd = [AVID_MXF_INFO_EXEC, path]
    #print subprocess.list2cmdline(cmd)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout,stderr = p.communicate()
    if p.returncode != 0:
        raise subprocess.CalledProcessError(p.returncode, subprocess.list2cmdline(cmd), stderr)

    file_package_uid = None
    reel_uid = None

    for line in stdout.splitlines():
        #print line
        if line.startswith("Physical package UID"):
            reel_uid = parse_umid(line)
        elif line.startswith("File package UID"):
            file_package_uid = parse_umid(line)
        elif line.startswith("Start timecode"):
            clip_start_timecode=(line.split("=")[1]).split()[0]
                #print 'clip start tc in frames='+clip_start_timecode
    return file_package_uid, reel_uid,clip_start_timecode






#if input is a folder make a list of files that are in it called "filelist"
if os.path.isdir(folderpath):
    filelist=listdir(folderpath)#listdir turns the contents of a folder into a list
else:
    #if input is a file set the list filelist to just the input path (called folderpath confusingly sorry)
    filelist=[folderpath]

f = aaf.open(os.path.join(mydesktop,outputname+".aaf"), 'w')#this gets ready to write the aaf file
comp_mob = f.create.CompositionMob()
timecode_mob=f.create.SourceMob()
comp_mob.name=outputname+" graded"+currentdate #this gives the name of the sequence in the bin
print >>output_text_file, "Sequence Name: \"",(outputname+" graded"+currentdate),"\"\n"



sequence = f.create.Sequence("picture")



timeline_slot = comp_mob.append_new_timeline_slot( video_rate, sequence)
timeline_slot.name=outputname+" graded"+currentdate #this gives the name of the LAYER in the sequence

f.storage.add_mob(comp_mob)


master_clips={}#make a master_clips dictionary to hold all the master clips in later

clipnum=1

for path in filelist:
    if '.mxf' in path:
        path=os.path.join(folderpath,path)
        print 'my path is '+path
        baselightfilename=(path.split("/")[-1])
        baselightjustname=(baselightfilename.split(".mxf")[0])
        print "name = "+baselightjustname
        mastermob = f.create.MasterMob()
        f.storage.add_mob(mastermob)
        data = probe(path)
        #pprint.pprint(data)
        # opatom mxf files should only have single streams
        format = data['format']
        metadata = format['tags']
        stream = data['streams'][0]
        stream_metadata = stream['tags']
        material_name = metadata['material_package_name']
        mastermob.name = material_name

        file_package_uuid = stream_metadata['file_package_uid']
        file_package_name = stream_metadata['file_package_name']
        #reel_name = stream_metadata['reel_name'] #this seems to choke on baselight made stuff
        reel_uid = stream_metadata['reel_uid']

        file_package_mob_id, reel_mob_id,clip_start_timecode = mxfinfo(path)
        codec_type = stream['codec_type']
        rate = fractions.Fraction(stream['avg_frame_rate'])
        duration = int(float(stream['duration']) * float(rate))

        print "file package mob id = ", file_package_mob_id
        print "duration of clip =", duration,"frames"

        if codec_type == 'video':
            media_kind = "picture"
            width = int(stream['width'])
            height = int(stream['height'])

            descriptor = f.create.CDCIDescriptor()

            descriptor['StoredHeight'].value = height
            descriptor['StoredWidth'].value = width
            descriptor['ImageAspectRatio'].value = fractions.Fraction(width, height)

        elif codec_type == 'audio':
            raise Exception("Audio not supported yet")
        else:
            raise Exception("Unknown media kind %s" % codec_type)

        descriptor['Length'].value = duration

        src_mob = f.create.SourceMob(file_package_name)
        src_mob.mobID = file_package_mob_id
        src_mob.essence_descriptor = descriptor
        src_mob.add_nil_ref(1, duration, media_kind, rate)
        f.storage.add_mob(src_mob)

        source_clip = src_mob.create_clip(1)

        mastermob.append_new_timeline_slot(rate, source_clip, 1)
        clip=mastermob.create_clip(1)

        master_clips.update({clip_start_timecode:clip})
        #sequence.append(clip) #if you have this here the clips just get butted together in the sequence ie not in the right place
        print >>output_text_file, "Clip",clipnum,baselightjustname,"Start",frames_to_timecode(int(clip_start_timecode)),"Duration",frames_to_timecode(int(clip.length))
        clipnum+=1
start = sorted(master_clips.keys())[0] #this gets the position of the first masterclip so sequence starts with it but sequence start tc is done by adding a timecode mob later
#start=90000 #other possibility (90000= 01:00:00:00  at 25fps as frame number) which makes the clip timecodes match the sequence timecode but has a large filler gap at the start of the sequence
print "start of sequence is ",frames_to_timecode(int(start))
total_clip_and_filler_length=0
for position, clip in  sorted(master_clips.items()):
    filler_length = int(position) - int(start)
    #print "position="+position
    #print "clip length="+str(clip.length)
    if filler_length > 0:
        filler = f.create.Filler("picture", filler_length)
        sequence.append(filler)
    sequence.append(clip)
    total_clip_and_filler_length=total_clip_and_filler_length +filler_length+clip.length
    start = int(position) + clip.length
    #print 'total lenth of seq so far is...'+str(total_clip_and_filler_length)


#add timecode mob to enable the start_tc of the sequence in Avid
seq_timecode = f.create.Timecode( total_clip_and_filler_length, int(sorted(master_clips.keys())[0]),video_rate)#first arg is length,2nd arg is start_tc,3rd Arg is timecode rate
timecode_slot=comp_mob.append_new_timeline_slot( video_rate, seq_timecode)
timecode_slot.name="TC 1"
#all this sets "mark in" and "mark out" on the sequence ready for copying by editor maybe not necessary!
timeline_slot['UserPos'].value=0
timeline_slot['MarkIn'].value=0
timeline_slot['MarkOut'].value=total_clip_and_filler_length

how_many_clips=len(master_clips)
print >>output_text_file, "\nTotal Number of Clips",how_many_clips



#print 'timeline origin frame '+str(int(sorted(master_clips.keys())[0])-timeline_slot.origin)

#info for learning here!!
#print
#print 'COMP MOB INFO'
#print comp_mob.properties()
#print comp_mob.all_keys()
#for thing in comp_mob.all_keys():
#    print str(thing)+" "+str(comp_mob[thing].value)

#print
#print 'SEQ MOB INFO'
#print sequence.properties()
#print sequence.all_keys()
#for thing in sequence.all_keys():
#    print str(thing) +" " +str(sequence[thing].value)

#print
#print 'TIMELINE SLOT INFO'
#print timeline_slot.properties()
#for thing in timeline_slot.all_keys():
#    print str(thing)+" "+str(timeline_slot[thing].value)
#for thingy in ((timeline_slot.segment)['Components'].value):
#    print 'clip length in sequence is '+str(thingy['Length'].value) +' frames'



f.save()
