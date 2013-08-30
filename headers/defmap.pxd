from libcpp.map cimport map
from libcpp.string cimport string
from libcpp.pair cimport pair

cdef extern from "AAFCodecDefs.h":
    cdef aafUID_t kAAFCodecDef_JPEG

cdef extern from "AAFContainerDefs.h":
    cdef aafUID_t kAAFContainerDef_AAF

cdef extern from "defmap.h":
    cdef map[string, aafUID_t] get_datadef_map()
    cdef map[string, aafUID_t] get_codecdef_map()
    cdef map[string, aafUID_t] get_container_def_map()
    cdef map[string, pair[aafUID_t, string] ] get_essenceformats_def_map()