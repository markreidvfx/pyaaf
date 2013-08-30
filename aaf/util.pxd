cimport lib

from libc.stddef cimport wchar_t

cdef object error_check(int ret)
cdef object query_interface(lib.IUnknown **src, lib.IUnknown **dst, lib.GUID guid)

cdef object register()


cdef lib.aafCharacter* aafChar(char* s)
cdef char* toChar(lib.aafCharacter* s)

cdef object register_object(object obj)
cdef object lookup_object(bytes name)

cdef object fraction_to_aafRational(object obj, lib.aafRational_t& r)

cdef fused aaf_integral:
    lib.aafInt8
    lib.aafInt16
    lib.aafInt32
    lib.aafInt64
    lib.aafUInt8
    lib.aafUInt16
    lib.aafUInt32
    lib.aafUInt64