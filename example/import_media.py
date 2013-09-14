import aaf
import traceback
import subprocess
import json
import os
import datetime

from pprint import pprint
def probe(path):
    
    cmd = ['ffprobe', '-of','json', '-show_streams', path]
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
        
def conform_media(path, start=None, end=None, duration=None):

    format = probe(path)
    
    out_files = []
    
    cmd = ['ffmpeg', '-y']
    
    if end:
        duration = timecode_to_seconds(end) - timecode_to_seconds(start)
        duration = seconds_to_timecode(duration)
        end = None
    
    if start:
        start_seconds = timecode_to_seconds(start)
        
        fast_start = max(0,int(start_seconds-30))
        
        #fast_start = seconds_to_timecode(fast_start)
        #raise Exception
        
        if fast_start:
            start = seconds_to_timecode(start_seconds - fast_start)
            cmd.extend(['-ss', seconds_to_timecode(fast_start)])
    

    
    #start = None
    
    
    cmd.extend([ '-i', path])
    
    frame_rate = '24000/1001'
    #sample_rate =44100
    sample_rate = 48000
    
    for stream in format['streams']:
        
        pprint(stream)
        stream_index = stream['index']
        if stream['codec_type'] == 'video':
            
            input_width = stream['width']
            input_height = stream['height']
            
            
            max_width = 1920
            max_height = 1080
            
            scale = min(max_width/ float(input_width), max_height/float(input_height) )
            
            scale_width = int(input_width*scale)
            scale_height = int(input_height*scale)

            padding_ofs_x = (max_width  - scale_width)/2
            padding_ofs_y = (max_height - scale_height)/2
            
            
            vfilter = "scale=%d:%d,pad=%d:%d:%d:%d" % (scale_width,scale_height,
                                                       max_width,max_height, padding_ofs_x,padding_ofs_y)
            
            print vfilter
            
            cmd.extend(['-an','-vcodec', 'dnxhd', '-vb', '36M', '-r', frame_rate])
            
            if not start is None:
                cmd.extend(['-ss', str(start)])
            
            if not duration is None:
                cmd.extend(['-t', str(duration)])
            
            cmd.extend(['-vf', vfilter])
            
            out_file = 'out_%d.dnxhd' % (stream_index)
            
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
            
            out_file = 'out_%d_%d_%d.pcm' % (stream_index, sample_rate, channels)
            
            cmd.extend([out_file])
            
            out_files.append({'path':out_file, 'sample_rate':sample_rate, 'channels':channels,'type': 'audio'})
            
            
    
    print subprocess.list2cmdline(cmd)
    
    subprocess.check_call(cmd)
    
    return out_files
        
        
def create_aaf(path, media_streams):
    
    f = aaf.open(path, 'rw')

    header = f.header()
    d = header.dictionary()
    
    
    mastermob = d.create.MasterMob("mastermob")
    header.append(mastermob)

    for stream in media_streams:
        if stream['type'] == 'video':
            mastermob.import_video_essence(stream['path'], stream['frame_rate'])
        if stream['type'] == 'audio':
            mastermob.import_audio_essence(stream['path'], stream['channels'], stream['sample_rate'])

    f.save()
    f.close()
    
    
    
if __name__ == "__main__":
    from optparse import OptionParser
    
    usage = "usage: %prog [options] output_aaf_file media_file"
    parser = OptionParser(usage=usage)
    parser.add_option('-s', '--start', type="string", dest="start",default=None,
                      help = "start recording at, in timecode or seconds [default]")
    parser.add_option('-e', '--end', type="string", dest='end',default=None,
                      help = "end recording at in timecode or seconds [default]")
    parser.add_option('-d', '--duration', type="string", dest='duration',default=None,
                      help = "record duration in timecode or seconds [default]")

    (options, args) = parser.parse_args()

    if len(args) < 2:
        parser.error("not enough args")
        
    if not os.path.exists(args[1]):
        parser.error("No such file or directory: %s" % args[1])
        
    if options.end and options.duration:
        parser.error("Can only use --duration or --end not both")
        
    
    aaf_file = args[0]
    try:
        media_streams =  conform_media(args[1], 
                                   start=options.start,
                                   end=options.end, 
                                   duration=options.duration)
    except:
        print traceback.format_exc()
        parser.error("error conforming media")
    
    create_aaf(aaf_file, media_streams)