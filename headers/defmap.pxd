from libcpp.map cimport map
from libcpp.string cimport string
from libcpp.pair cimport pair

cdef extern from "AAFCodecDefs.h":
    cdef aafUID_t kAAFCodecDef_JPEG

cdef extern from "AAFContainerDefs.h":
    cdef aafUID_t kAAFContainerDef_AAF

cdef extern from "AAFTypeDefUIDs.h":
    cdef aafUID_t kAAFTypeID_AUID
    cdef aafUID_t kAAFTypeID_DateStruct
    cdef aafUID_t kAAFTypeID_MobIDType
    cdef aafUID_t kAAFTypeID_TimeStruct
    cdef aafUID_t kAAFTypeID_TimeStamp
    cdef aafUID_t kAAFTypeID_Boolean
    cdef aafUID_t kAAFTypeID_Rational


cdef extern from "defmap.h":
    cdef map[string, aafUID_t] get_typedef_map()
    cdef map[string, aafUID_t] get_datadef_map()
    cdef map[string, aafUID_t] get_codecdef_map()
    cdef map[string, aafUID_t] get_container_def_map()
    cdef map[string, aafUID_t] get_compressiondef_map()
    cdef map[string, aafUID_t] get_extenumdef_map()
    cdef map[string, aafUID_t] get_interpolationdef_map()
    cdef map[string, pair[aafUID_t, string] ] get_essenceformats_def_map()
