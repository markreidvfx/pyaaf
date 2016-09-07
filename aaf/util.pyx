
cimport lib

from wstring cimport wstring, toWideString, wideToString, print_wchar
from libcpp.string cimport string
from libcpp.vector cimport vector
from libc.stddef cimport wchar_t
from libc.string cimport memset, memcpy

from .fraction_util import AAFFraction

import uuid

# This function is defined in the define module
# and set via set_resolver_func to avoid import base into this module
cdef object RESOLVE_OBJECT_FUNC = None

cdef dict OBJECT_MAP = {}

cpdef object error_check(lib.HRESULT ret):
    if not lib.SUCCEEDED(ret):
        message = HRESULT2str(ret)
        raise RuntimeError("failed with [%d]: %s" % (ret, message))

    return ret

cdef object HRESULT2str(lib.HRESULT result):
    cdef lib.aafUInt32 size_in_bytes
    ret = lib.AAFResultToTextBufLen(result, &size_in_bytes)

    if not lib.SUCCEEDED(ret):
        return "Unknown Error"


    cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)
    buf.size_in_bytes = size_in_bytes

    ret = lib.AAFResultToText(result, buf.get_ptr(), buf.size_in_bytes)

    if not lib.SUCCEEDED(ret):
        return "Unknown Error"

    message = buf.read_str()
    message = message.replace("AAFRESULT_", "").replace("_", " ").lower()
    return message

cdef object query_interface(lib.IUnknown **src, lib.IUnknown **dst, lib.GUID guid):
    cdef lib.HRESULT ret
    with nogil:
        if not src[0]:
            with gil: raise RuntimeError("src can not be a null pointer")
        if dst[0]:
            with gil: raise RuntimeError("dst needs to be a null pointer")
        ret = src[0].QueryInterface(guid, <void**> dst)
    error_check(ret)

cdef object register_object(object obj):
    global OBJECT_MAP
    OBJECT_MAP[obj.__name__] = obj

cdef object lookup_object(object name):
    global OBJECT_MAP
    rename = name
    for n,r in (("",""), ("Definition", "Def")):
        rename = rename.replace(n,r)
        if rename in OBJECT_MAP:
            return OBJECT_MAP[rename]
    return None

cdef object set_resolve_object_func(object obj):
    global RESOLVE_OBJECT_FUNC
    RESOLVE_OBJECT_FUNC = obj

cdef object resolve_object(object obj):
    return RESOLVE_OBJECT_FUNC(obj)

cdef object fraction_to_aafRational(object obj, lib.aafRational_t& r):

    f = AAFFraction(obj).limit_denominator(200000000)
    r.numerator = f.numerator
    r.denominator = f.denominator

cdef object aafRational_to_fraction(lib.aafRational_t& r):

    return AAFFraction(r.numerator, r.denominator)

# Utility Classes
include "util/AAFCharBuffer.pyx"
include "util/AUID.pyx"
include "util/MobID.pyx"
include "util/SourceRef.pyx"
include "util/Timecode.pyx"
include "util/progress_callback.pyx"
include "util/diagnostic_output.pyx"

cdef dict VersionTypes = {'Unknown' : 0,
                          'Released' : 1,
                          'Debug' : 2,
                          'Patched' : 3,
                          'Beta' : 4,
                          'PrivateBuild' : 5}

def get_library_version():
    cdef lib.aafProductVersion_t version
    error_check(lib.AAFGetLibraryVersion(&version))
    dict_version = dict(version)

    # set a nicer VersionType name
    for key, value in VersionTypes.items():
        if dict_version['type'] == value:
            dict_version['type'] = key
            break
    else:
        dict_version['type'] = "Unknown"

    return dict_version

def get_static_library_version():
    cdef lib.aafProductVersion_t version
    error_check(lib.AAFGetStaticLibraryVersion(&version))
    dict_version = dict(version)

    # set a nicer VersionType name
    for key, value in VersionTypes.items():
        if dict_version['type'] == value:
            dict_version['type'] = key
            break
    else:
        dict_version['type'] = "Unknown"

    return dict_version

def get_library_path_name():
    cdef lib.aafUInt32 size_in_bytes
    error_check(lib.AAFGetLibraryPathNameBufLen(&size_in_bytes))

    cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)
    buf.size_in_bytes =  size_in_bytes

    error_check(lib.AAFGetLibraryPathName(buf.get_ptr(), size_in_bytes))

    return buf.read_str()
