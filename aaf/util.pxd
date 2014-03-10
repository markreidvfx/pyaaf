cimport lib

from libc.stddef cimport wchar_t
from libcpp.string cimport string
from libcpp.vector cimport vector
from wstring cimport wstring

cdef object error_check(int ret)
cdef object query_interface(lib.IUnknown **src, lib.IUnknown **dst, lib.GUID guid)

cdef object register_object(object obj)
cdef object lookup_object(bytes name)

cdef object resolve_object(object obj)
cdef object set_resolve_object_func(object obj)

cdef object fraction_to_aafRational(object obj, lib.aafRational_t& r)
cdef object aafRational_to_fraction(lib.aafRational_t& r)

cdef class WCharBuffer(object):
    cdef vector[lib.aafCharacter] buf
    cdef from_wstring(self, wstring value)
    cdef from_string(self, bytes value)
    cdef bytes to_string(self)
    cdef wstring to_wstring(self)
    cdef wchar_t * to_wchar(self)
    cdef set_size(self, size_t size)
    cdef size_t size(self)
    cdef size_t size_in_bytes(self)
    
cdef class SourceRef(object):
    cdef lib.aafSourceRef_t source_ref
    cdef lib.aafSourceRef_t get_aafSourceRef_t(self)

cdef class Timecode(object):
    cdef lib.aafTimecode_t timecode
    cdef lib.aafTimecode_t get_timecode_t(self)
    
cdef class AUID(object):
    cdef lib.aafUID_t auid
    cdef lib.aafUID_t get_auid(self)
    cdef lib.GUID get_iid(self)
    cdef void from_auid(self, lib.aafUID_t auid)
    cdef void from_iid(self, lib.GUID iid)
    
cdef class MobID(object):
    cdef lib.aafMobID_t mobID
    cdef lib.aafMobID_t get_aafMobID_t(self)

cdef fused aaf_integral:
    lib.aafInt8
    lib.aafInt16
    lib.aafInt32
    lib.aafInt64
    lib.aafUInt8
    lib.aafUInt16
    lib.aafUInt32
    lib.aafUInt64