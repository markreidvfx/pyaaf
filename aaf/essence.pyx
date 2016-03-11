cimport lib

from .util cimport error_check, query_interface, register_object, aaf_integral, fraction_to_aafRational, aafRational_to_fraction, AUID, AAFCharBuffer
from .base cimport AAFObject, AAFBase
from .define cimport DataDef, DataDefMap, ContainerDef, CompressionDefMap, ContainerDefMap, CodecDefMap
from .mob cimport SourceMob
from .dictionary cimport Dictionary
from .iterator cimport LocatorIter

from libcpp.map cimport map
from libcpp.string cimport string
from libcpp.pair cimport pair
from libcpp.vector cimport vector

from wstring cimport wstring, wideToString, toWideString

cpdef dict EssenceFormatDefMap = {}

cpdef dict ColorSpace = {}

ColorSpace['yuv'] = lib.kAAFColorSpaceYUV
ColorSpace['yiq'] = lib.kAAFColorSpaceYIQ
ColorSpace['hsi'] = lib.kAAFColorSpaceHSI
ColorSpace['hsv'] = lib.kAAFColorSpaceHSV
ColorSpace['ycrcb'] = lib.kAAFColorSpaceYCrCb
ColorSpace['ydrdb'] = lib.kAAFColorSpaceYDrDb
ColorSpace['cmyk'] = lib.kAAFColorSpaceCMYK

cpdef dict FrameLayout = {}

FrameLayout['fullframe'] = lib.kAAFFullFrame
FrameLayout['separatefields'] = lib.kAAFSeparateFields
FrameLayout['onefield'] = lib.kAAFOneField
FrameLayout['mixedfields'] = lib.kAAFMixedFields
FrameLayout['segmentedframe'] = lib.kAAFSegmentedFrame

cpdef dict ColorSiting = {}


ColorSiting['cositing'] = lib.kAAFCoSiting
ColorSiting['averaging'] = lib.kAAFAveraging
ColorSiting['threetap'] = lib.kAAFThreeTap
ColorSiting['quincunx'] = lib.kAAFQuincunx
ColorSiting['rec601'] = lib.kAAFRec601
ColorSiting['unknownsiting'] = lib.kAAFUnknownSiting

cdef register_formatdefs(map[string, pair[ lib.aafUID_t, string] ] def_map, dict d, replace=[]):
    cdef pair[string, pair[lib.aafUID_t, string] ] def_pair
    cdef AUID auid_obj
    for pair in def_map:
        auid_obj = AUID()
        auid_obj.from_auid(pair.second.first)
        name = pair.first.decode('ascii')
        for n in replace:
            name = name.replace(n, '')
        d[name.lower()] = (auid_obj, pair.second.second.decode('ascii'))

register_formatdefs(lib.get_essenceformats_def_map(), EssenceFormatDefMap, ['kAAF'])

include "essence/EssenceData.pyx"
include "essence/EssenceFormat.pyx"
include "essence/EssenceMultiAccess.pyx"
include "essence/EssenceAccess.pyx"

include "essence/Locator.pyx"
include "essence/NetworkLocator.pyx"

include "essence/EssenceDescriptor.pyx"
include "essence/FileDescriptor.pyx"
include "essence/WAVEDescriptor.pyx"
include "essence/AIFCDescriptor.pyx"
include "essence/TIFFDescriptor.pyx"
include "essence/DigitalImageDescriptor.pyx"
include "essence/CDCIDescriptor.pyx"
include "essence/RGBADescriptor.pyx"
include "essence/SoundDescriptor.pyx"
include "essence/PCMDescriptor.pyx"
include "essence/TapeDescriptor.pyx"
include "essence/PhysicalDescriptor.pyx"
include "essence/ImportDescriptor.pyx"

register_object(EssenceData)
register_object(Locator)
register_object(NetworkLocator)
register_object(EssenceDescriptor)
register_object(FileDescriptor)
register_object(WAVEDescriptor)
register_object(AIFCDescriptor)
register_object(TIFFDescriptor)
register_object(DigitalImageDescriptor)
register_object(CDCIDescriptor)
register_object(RGBADescriptor)
register_object(SoundDescriptor)
register_object(PCMDescriptor)
register_object(TapeDescriptor)
register_object(PhysicalDescriptor)
register_object(ImportDescriptor)
