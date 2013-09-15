from libcpp.string cimport string
from libcpp.map cimport map

cdef extern from "hrmap.h":
    cdef map[HRESULT, string] get_hrmap()
    
cdef extern from "AAFCOMPlatformTypes.h":
    cdef int SUCCEEDED(int status)
    
cdef extern from "AAFResult.h":
    cdef int AAFRESULT_SUCCESS
    cdef int AAFRESULT_NOT_OPEN
    cdef int AAFRESULT_NO_MORE_OBJECTS
    cdef int AAFRESULT_EOF