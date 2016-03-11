from libcpp.string cimport string
from libcpp.map cimport map

cdef extern from "AAFCOMPlatformTypes.h":
    cdef int SUCCEEDED(int status)

cdef extern from "AAFResult.h":
    cdef int AAFRESULT_SUCCESS
    cdef int AAFRESULT_NOT_OPEN
    cdef int AAFRESULT_NO_MORE_OBJECTS
    cdef int AAFRESULT_EOF
    cdef int AAFRESULT_END_OF_DATA
    cdef int AAFRESULT_PROP_NOT_PRESENT
    cdef int AAFRESULT_IS_ROOT_CLASS
    cdef int AAFRESULT_UNEXPECTED_EXCEPTION
    cdef int AAFRESULT_MOB_NOT_FOUND
