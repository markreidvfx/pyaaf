import aaf
import traceback
import subprocess
import json
import os
import datetime
import sys
import tempfile
import shutil
import time

from pprint import pprint

FFMPEG_EXEC = "ffmpeg"
FFPROBE_EXEC = "ffprobe"

Audio_Profiles = {
'pcm_32000':{'sample_fmt':'s16le','sample_rate':32000},
'pcm_44100':{'sample_fmt':'s16le','sample_rate':44100},
'pcm_48000':{'sample_fmt': 's16le','sample_rate':48000}
}

Video_Profiles ={
'dnx_1080p_175x_23.97': { "size":"1920x1080p", "bitrate":175, "pix_fmt":"yuv422p10", "frame_rate":"24000/1001", "codec": "dnxhd"},
'dnx_1080p_365x_50'   : { "size":"1920x1080p", "bitrate":185, "pix_fmt":"yuv422p10", "frame_rate":"25/1",       "codec": "dnxhd"},
'dnx_1080p_365x_60'   : { "size":"1920x1080p", "bitrate":365, "pix_fmt":"yuv422p10", "frame_rate":"50/1",       "codec": "dnxhd"},
'dnx_1080p_440x_23.97': { "size":"1920x1080p", "bitrate":440, "pix_fmt":"yuv422p10", "frame_rate":"60000/1001", "codec": "dnxhd"},
'dnx_1080p_115_23.97' : { "size":"1920x1080p", "bitrate":115, "pix_fmt":"yuv422p",   "frame_rate":"24000/1001", "codec": "dnxhd"},
'dnx_1080p_120_25'    : { "size":"1920x1080p", "bitrate":120, "pix_fmt":"yuv422p",   "frame_rate":"25/1",       "codec": "dnxhd"},
'dnx_1080p_145_29.97' : { "size":"1920x1080p", "bitrate":145, "pix_fmt":"yuv422p",   "frame_rate":"30000/1001", "codec": "dnxhd"},
'dnx_1080p_240_50'    : { "size":"1920x1080p", "bitrate":240, "pix_fmt":"yuv422p",   "frame_rate":"50/1",       "codec": "dnxhd"},
'dnx_1080p_290_59.94' : { "size":"1920x1080p", "bitrate":290, "pix_fmt":"yuv422p",   "frame_rate":"60000/1001", "codec": "dnxhd"},
'dnx_1080p_175_23.97' : { "size":"1920x1080p", "bitrate":175, "pix_fmt":"yuv422p",   "frame_rate":"24000/1001", "codec": "dnxhd"},
'dnx_1080p_185_25'    : { "size":"1920x1080p", "bitrate":185, "pix_fmt":"yuv422p",   "frame_rate":"25/1",       "codec": "dnxhd"},
'dnx_1080p_220_29.97' : { "size":"1920x1080p", "bitrate":220, "pix_fmt":"yuv422p",   "frame_rate":"30000/1001", "codec": "dnxhd"},
'dnx_1080p_365_50'    : { "size":"1920x1080p", "bitrate":365, "pix_fmt":"yuv422p",   "frame_rate":"50/1",       "codec": "dnxhd"},
'dnx_1080p_440_59.94' : { "size":"1920x1080p", "bitrate":440, "pix_fmt":"yuv422p",   "frame_rate":"60000/1001", "codec": "dnxhd"},
'dnx_1080i_185x_25'   : { "size":"1920x1080i", "bitrate":185, "pix_fmt":"yuv422p10", "frame_rate":"25/1",       "codec": "dnxhd"},
'dnx_1080i_220x_29.97': { "size":"1920x1080i", "bitrate":220, "pix_fmt":"yuv422p10", "frame_rate":"30000/1001", "codec": "dnxhd"},
'dnx_1080i_120_25'    : { "size":"1920x1080i", "bitrate":120, "pix_fmt":"yuv422p",   "frame_rate":"25/1",       "codec": "dnxhd"},
'dnx_1080i_145_29.97' : { "size":"1920x1080i", "bitrate":145, "pix_fmt":"yuv422p",   "frame_rate":"30000/1001", "codec": "dnxhd"},
'dnx_1080i_185_25'    : { "size":"1920x1080i", "bitrate":185, "pix_fmt":"yuv422p",   "frame_rate":"25/1",       "codec": "dnxhd"},
'dnx_1080i_220_29.97' : { "size":"1920x1080i", "bitrate":220, "pix_fmt":"yuv422p",   "frame_rate":"30000/1001", "codec": "dnxhd"},
'dnx_720p_90x_23.97'  : { "size":"1280x720p",  "bitrate":90,  "pix_fmt":"yuv422p10", "frame_rate":"24000/1001", "codec": "dnxhd"},
'dnx_720p_90x_25'     : { "size":"1280x720p",  "bitrate":90,  "pix_fmt":"yuv422p10", "frame_rate":"25/1",       "codec": "dnxhd"},
'dnx_720p_180x_50'    : { "size":"1280x720p",  "bitrate":180, "pix_fmt":"yuv422p10", "frame_rate":"50/1",       "codec": "dnxhd"},
'dnx_720p_220x_59.94' : { "size":"1280x720p",  "bitrate":220, "pix_fmt":"yuv422p10", "frame_rate":"60000/1001", "codec": "dnxhd"},
'dnx_720p_90_23.97'   : { "size":"1280x720p",  "bitrate":90,  "pix_fmt":"yuv422p",   "frame_rate":"24000/1001", "codec": "dnxhd"},
'dnx_720p_90_25'      : { "size":"1280x720p",  "bitrate":90,  "pix_fmt":"yuv422p",   "frame_rate":"25/1",       "codec": "dnxhd"},
'dnx_720p_110_29.97'  : { "size":"1280x720p",  "bitrate":110, "pix_fmt":"yuv422p",   "frame_rate":"30000/1001", "codec": "dnxhd"},
'dnx_720p_180_50'     : { "size":"1280x720p",  "bitrate":180, "pix_fmt":"yuv422p",   "frame_rate":"50/1",       "codec": "dnxhd"},
'dnx_720p_220_59.94'  : { "size":"1280x720p",  "bitrate":220, "pix_fmt":"yuv422p",   "frame_rate":"60000/1001", "codec": "dnxhd"},
'dnx_720p_60_23.97'   : { "size":"1280x720p",  "bitrate":60,  "pix_fmt":"yuv422p",   "frame_rate":"24000/1001", "codec": "dnxhd"},
'dnx_720p_60_25'      : { "size":"1280x720p",  "bitrate":60,  "pix_fmt":"yuv422p",   "frame_rate":"25/1",       "codec": "dnxhd"},
'dnx_720p_75_29.97'   : { "size":"1280x720p",  "bitrate":75,  "pix_fmt":"yuv422p",   "frame_rate":"30000/1001", "codec": "dnxhd"},
'dnx_720p_120_50'     : { "size":"1280x720p",  "bitrate":120, "pix_fmt":"yuv422p",   "frame_rate":"50/1",       "codec": "dnxhd"},
'dnx_720p_145_59.94'  : { "size":"1280x720p",  "bitrate":145, "pix_fmt":"yuv422p",   "frame_rate":"60000/1001", "codec": "dnxhd"},
'dnx_1080p_36_23.97'  : { "size":"1920x1080p", "bitrate":36,  "pix_fmt":"yuv422p",   "frame_rate":"24000/1001", "codec": "dnxhd"},
'dnx_1080p_36_25'     : { "size":"1920x1080p", "bitrate":36,  "pix_fmt":"yuv422p",   "frame_rate":"25/1",       "codec": "dnxhd"},
'dnx_1080p_45_29.97'  : { "size":"1920x1080p", "bitrate":45,  "pix_fmt":"yuv422p",   "frame_rate":"30000/1001", "codec": "dnxhd"},
'dnx_1080p_75_50'     : { "size":"1920x1080p", "bitrate":75,  "pix_fmt":"yuv422p",   "frame_rate":"50/1",       "codec": "dnxhd"},
'dnx_1080p_90_59.94'  : { "size":"1920x1080p", "bitrate":90,  "pix_fmt":"yuv422p",   "frame_rate":"60000/1001", "codec": "dnxhd"}}


def probe(path):

    cmd = [FFPROBE_EXEC, '-of','json','-show_format','-show_streams', path]
    print subprocess.list2cmdline(cmd)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    stdout,stderr = p.communicate()

    if p.returncode != 0:
        raise subprocess.CalledProcessError(p.returncode, subprocess.list2cmdline(cmd), stderr)


    return json.loads(stdout)


def timecode_to_seconds(time_string):
    try:
        return float(time_string)
    except:
        pass

    for format in ("%H:%M:%S.%f", "%H:%M:%S", "%M:%S.%f","%M:%S"):
        try:
            t = datetime.datetime.strptime(time_string, format)

            seconds = 0

            if t.minute:
                seconds += 60*t.minute

            if t.hour:
                seconds += 60 * 60 * t.hour
            seconds += t.second
            seconds += float(t.strftime(".%f"))

            return seconds
        except:
            #print traceback.format_exc()
            pass

    raise ValueError("invalid time format: %s" % time_string)

def seconds_to_timecode(seconds):
    format = "%S.%f"
    t = datetime.timedelta(seconds=float(seconds))


    return str(t)

def conform_media(path,output_dir, start=None, end=None, duration=None, video_profile=None, audio_profile=None):

    if not video_profile:
        video_profile = 'dnx_1080p_36_23.97'
    if not audio_profile:
        audio_profile = 'pcm_48000'

    video_profile = Video_Profiles[video_profile]
    audio_profile = Audio_Profiles[audio_profile]

    format = probe(path)

    out_files = []

    cmd = [FFMPEG_EXEC,'-y', '-nostdin']

    if end:
        duration = timecode_to_seconds(end) - timecode_to_seconds(start)
        duration = seconds_to_timecode(duration)
        end = None

    if start:
        start_seconds = timecode_to_seconds(start)

        fast_start = max(0,int(start_seconds-30))

        if fast_start:
            start = seconds_to_timecode(start_seconds - fast_start)
            cmd.extend(['-ss', seconds_to_timecode(fast_start)])

    frame_rate = video_profile['frame_rate']
    pix_fmt = video_profile['pix_fmt']
    bitrate = video_profile['bitrate']

    if format['format']['format_name'] == "image2":
        cmd.extend([ '-r', frame_rate])

    cmd.extend(['-i', path,])



    width, height = video_profile['size'].split('x')

    interlaced = False

    if height[-1] == 'i':
        interlaced = True
    width = int(width)
    height = int(height[:-1])

    #sample_rate =44100
    sample_rate = audio_profile['sample_rate']

    for stream in format['streams']:

        pprint(stream)
        stream_index = stream['index']
        if stream['codec_type'] == 'video':

            input_width = stream['width']
            input_height = stream['height']


            max_width = width
            max_height = height

            scale = min(max_width/ float(input_width), max_height/float(input_height) )

            scale_width = int(input_width*scale)
            scale_height = int(input_height*scale)

            padding_ofs_x = (max_width  - scale_width)/2
            padding_ofs_y = (max_height - scale_height)/2


            vfilter = "scale=%d:%d,pad=%d:%d:%d:%d" % (scale_width,scale_height,
                                                       max_width,max_height, padding_ofs_x,padding_ofs_y)

            print vfilter

            cmd.extend(['-an','-vcodec', 'dnxhd', '-vb', '%dM' % bitrate, '-r', frame_rate, '-pix_fmt', pix_fmt])

            if not start is None:
                cmd.extend(['-ss', str(start)])

            if not duration is None:
                cmd.extend(['-t', str(duration)])

            cmd.extend(['-vf', vfilter])

            out_file = os.path.join(output_dir, 'out_%d.dnxhd' % (stream_index))

            cmd.extend([out_file])

            out_files.append({'path':out_file, 'frame_rate':frame_rate, 'type': 'video'})

        elif stream['codec_type'] == 'audio':

            input_sample_rate = int(stream['sample_rate'])
            channels = stream['channels']

            cmd.extend(['-vn', '-acodec', 'pcm_s16le','-f','s16le', '-ar', str(sample_rate)])

            if not start is None:
                cmd.extend(['-ss', str(start)])

            if not duration is None:
                cmd.extend(['-t', str(duration)])

            out_file = os.path.join(output_dir, 'out_%d_%d_%d.pcm' % (stream_index, sample_rate, channels))

            cmd.extend([out_file])

            out_files.append({'path':out_file, 'sample_rate':sample_rate, 'channels':channels,'type': 'audio'})



    print subprocess.list2cmdline(cmd)

    subprocess.check_call(cmd)

    return out_files


def create_aaf(path, media_streams, mobname):

    f = aaf.open(path, 'rw')

    mastermob = f.dictionary.create.MasterMob(mobname)
    f.storage.add_mob(mastermob)

    for stream in media_streams:
        if stream['type'] == 'video':
            print "importing video..."
            start = time.time()
            mastermob.import_video_essence(stream['path'], stream['frame_rate'])
            print "imported video in %d secs" % (time.time()- start)
        if stream['type'] == 'audio':
            print "importing audio..."
            start = time.time()
            mastermob.import_audio_essence(stream['path'], stream['channels'], stream['sample_rate'])

            print "imported audio in %d secs" % (time.time()- start)

    f.save()
    f.close()



if __name__ == "__main__":
    from optparse import OptionParser

    usage = "usage: %prog [options] output_aaf_file media_file"
    parser = OptionParser(usage=usage)
    parser.add_option('-s', '--start', type="string", dest="start",default=None,
                      help = "start recording at, in timecode or seconds")
    parser.add_option('-e', '--end', type="string", dest='end',default=None,
                      help = "end recording at in timecode or seconds")
    parser.add_option('-d', '--duration', type="string", dest='duration',default=None,
                      help = "record duration in timecode or seconds")

    parser.add_option("-v", '--video-profile', type='string', dest = 'video_profile', default="dnx_1080p_36_23.97",
                      help = "encoding profile for video [default: 1080p_36_23.97]")
    parser.add_option("-a", '--audio-profile', type='string', dest = 'audio_profile',default='pcm_48000',
                      help = 'encoding profile for audio [default: pcm_48000]')

    parser.add_option('--list-profiles', dest='list_profiles',
                      action="store_true",default=False,
                      help = "lists profiles")

    (options, args) = parser.parse_args()


    if options.list_profiles:

        titles = ['Audio Profile', 'Sample Rate', 'Sample Fmt']
        row_format ="{:<25}{:<15}{:<15}"

        print ""
        print row_format.format( *titles)
        print ""

        for key,value in sorted(Audio_Profiles.items()):
            print row_format.format(key, value['sample_rate'], value['sample_fmt'])

        titles = ['Video Profile', "Size", 'Frame Rate', "Bitrate", "Pix Fmt", "Codec"]
        row_format ="{:<25}{:<15}{:<15}{:<10}{:<12}{:<10}"
        print ""
        print row_format.format( *titles)
        print ""
        for key, value in sorted(Video_Profiles.items()):
            print row_format.format(key, value['size'],
                                    value['frame_rate'], value['bitrate'], value['pix_fmt'], value['codec'])

        sys.exit()

    if len(args) < 2:
        parser.error("not enough args")

    details = probe(args[1])

    #if not os.path.exists(args[1]):
        #parser.error("No such file or directory: %s" % args[1])

    if options.end and options.duration:
        parser.error("Can only use --duration or --end not both")

    if not Audio_Profiles.has_key(options.audio_profile.lower()):
        parser.error("No such audio profile: %s" % options.audio_profile)

    if not Video_Profiles.has_key(options.video_profile.lower()):
        parser.error("No such video profile: %s" % options.video_profile)

    aaf_file = args[0]


    tempdir = tempfile.mkdtemp("-aaf_import")
    print tempdir
    try:
        media_streams =  conform_media(args[1],
                                       output_dir=tempdir,
                                       start=options.start,
                                       end=options.end,
                                       duration=options.duration,
                                       video_profile = options.video_profile.lower(),
                                       audio_profile = options.audio_profile.lower())
    except:
        print traceback.format_exc()
        shutil.rmtree(tempdir)
        parser.error("error conforming media")

    try:
        basename = os.path.basename(args[1])
        name,ext = os.path.splitext(basename)
        if details['format']['format_name'] == 'image2':
            name, padding = os.path.splitext(name)
        create_aaf(aaf_file, media_streams,name)
    finally:
        shutil.rmtree(tempdir)
