
cimport lib

from wstring cimport wstring, toWideString, wideToString, print_wchar
from libcpp.string cimport string
from libcpp.vector cimport vector
from libc.stddef cimport wchar_t

from .fraction_util import AAFFraction

import uuid

# This function is defined in the define module
# and set via set_resolver_func to avoid import base into this module
cdef object RESOLVE_OBJECT_FUNC = None

cdef dict OBJECT_MAP = {}

cdef object error_check(int ret):
    if not lib.SUCCEEDED(ret):
        message = HRESULT2str(ret)
        raise RuntimeError("failed with [%d]: %s" % (ret, message))
    
    return ret

cdef object HRESULT2str(lib.HRESULT result):
    cdef lib.aafUInt32 bufflen
    ret = lib.AAFResultToTextBufLen(result, &bufflen)
    
    if not lib.SUCCEEDED(ret):
        return "Unknown Error"
    
    cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](bufflen)
    cdef lib.aafUInt32 bytes_read
    
    ret = lib.AAFResultToText(result,
                              &buf[0],
                              bufflen
                              )
    
    if not lib.SUCCEEDED(ret):
        return "Unknown Error"
    
    cdef wstring name = wstring(&buf[0])
    message = wideToString(name)
    message = message.replace("AAFRESULT_", "").replace("_", " ").lower()    
    return message

cdef object query_interface(lib.IUnknown **src, lib.IUnknown **dst, lib.GUID guid):
    if not src[0]:
        raise RuntimeError("src can not be a null pointer")
    if dst[0]:
        raise RuntimeError("dst needs to be a null pointer")
    
    error_check(src[0].QueryInterface(guid, <void**> dst))

cdef object register_object(object obj):
    global OBJECT_MAP
    OBJECT_MAP[obj.__name__] = obj

cdef object lookup_object(bytes name):
    global OBJECT_MAP
    rename = name
    for n,r in (("",""), ("Definition", "Def")):
        rename = rename.replace(n,r)
        if OBJECT_MAP.has_key(rename):
            return OBJECT_MAP[rename]
    raise KeyError("No object named %s" % name)

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

cdef class WCharBuffer(object):
    
    cdef from_wstring(self, wstring value):
        self.buf = vector[lib.aafCharacter]()
        cdef const wchar_t *ptr = value.c_str()
        cdef wchar_t item
        for i in xrange(value.size()):
            item = ptr[i]
            self.buf.push_back(item)
        # Added null terminator
        self.buf.push_back('\0')
        
    cdef from_string(self, bytes value):
        self.from_wstring(toWideString(value))
        
    cdef bytes to_string(self):
        return wideToString(self.to_wstring())
    
    cdef wstring to_wstring(self):
        cdef wstring value = wstring(&self.buf[0], self.buf.size())
        return value

    cdef wchar_t* to_wchar(self):
        return <wchar_t *> &self.buf[0]
    
    cdef set_size(self, size_t size):
        self.buf = vector[lib.aafCharacter](size)
    
    cdef size_t size(self):
        return self.buf.size()
    
    cdef size_t size_in_bytes(self):
        return self.buf.size() * sizeof(lib.aafCharacter)
    
    def __str__(self):
        return self.to_string()

# Utility Classes

include "util/AUID.pyx"
include "util/MobID.pyx"
include "util/SourceRef.pyx"
include "util/Timecode.pyx"
        
