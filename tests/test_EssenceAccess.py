from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.component

import unittest
import traceback

import os

import uuid

cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)


from test_import import generate_pcm_audio_mono

import wave
#CreateAudioAAFFile(
#    aafWChar * pFileName,
#    aafUID_constref fileKind,
#    testRawStorageType_t rawStorageType,
#    aafProductIdentification_constref productID,
#    testDataFile_t *dataFile,
#    testType_t testType,
#    aafUID_t codecID,
#    aafUID_t ddefID,
#    aafBool bCallSetTransformParameters=kAAFFalse)

class TestEssenceAccess(unittest.TestCase):

    #CreateAudioAAFFile(metadataFileName, fileKind, rawStorageType, productID,
    #NULL, testStandardCalls, kAAFCodecWAVE, kAAFDataDef_Sound, kAAFTrue)
    def test_audio_aaf_file(self):
        test_file = os.path.join(sandbox, "EssenceAccessWAVE.aaf")
        export_file = os.path.join(sandbox, "EssenceAccessWAVE_export.wav")
        f = aaf.open(test_file, 'w')

        wave_audio_file_path = generate_pcm_audio_mono("EssenceAccessWAVE",sample_rate = 48000, duration = 2, format='wav')

        mob = f.create.MasterMob()
        f.storage.add_mob(mob)


        wave_file  = wave.open(wave_audio_file_path, 'r')

        bitsPerSample = wave_file.getsampwidth()
        numCh = wave_file.getnchannels()
        sampleRate = wave_file.getframerate()
        audiosamplebits =  bitsPerSample * 8

        samples = wave_file.getnframes()

        print(bitsPerSample,numCh, sampleRate)

        essence_access = mob.create_essence(1, "Sound", "WAVE", sampleRate, sampleRate, False, )

        codecID = essence_access.codecID

        format = essence_access.get_emptyfileformat()

        format['audiosamplebits'] = audiosamplebits
        format['numchannels'] = numCh
        format['samplerate'] = sampleRate

        essence_access.set_fileformat(format)

        # Flavour_None is the only one available for CodecWAVE
        essence_access.codec_flavour = "Flavour_None"

        essence_access.write(wave_file.readframes(samples), samples)

        essence_access.complete_write()

        f.save()
        f.close()

        # now open file and verify data

        f = aaf.open(test_file, 'r')

        mob = f.storage.master_mobs()[0]

        essence_access = mob.open_essence(1)

        format = essence_access.get_fileformat()

        assert format['audiosamplebits'] == audiosamplebits
        assert format['numchannels'] == numCh
        assert format['samplerate'] == sampleRate

        data = essence_access.read(samples)

        export_wave = wave.open(export_file, 'wb')

        export_wave.setsampwidth(int(audiosamplebits/8))
        export_wave.setnchannels(numCh)
        export_wave.setframerate(sampleRate)

        #print(dir(export_wave))
        export_wave.writeframesraw(data)
        export_wave.close()

if __name__ == "__main__":
    unittest.main()
