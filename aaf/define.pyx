
cimport lib
from .base cimport AAFBase, AAFObject
from .util cimport error_check, query_interface, aaf_integral, register_object, lookup_object, set_resolve_object_func, AUID, MobID, AAFCharBuffer
from .property cimport PropertyValue

from .iterator cimport PropertyDefsIter, TypeDefStreamDataIter, PropValueIter, PropValueResolveIter
from .dictionary cimport Dictionary
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.pair cimport pair
from libcpp.map cimport map
from wstring cimport  wstring, wideToString, toWideString

import traceback
from fraction_util import AAFFraction

cdef object isA(AAFBase obj1,obj2):
    cdef AAFBase test_obj
    try:
        test_obj = obj2.__new__(obj2)
        test_obj.query_interface(obj1)
        #obj2(obj1)
    except:
        return False

    return True

def resolve_closest_class(ClassDef classdef not None):
    while classdef:
        obj_type = lookup_object(classdef.name)
        if obj_type:
            return obj_type
        classdef = classdef.parent()

def resolve_object_func(AAFBase obj):
    """
    resolve any AAFBase object into it highest level class
    """
    cdef AAFBase new_obj
    cdef AAFObject test_aaf_obj

    if isA(obj, AAFObject):

        test_aaf_obj = AAFObject.__new__(AAFObject)
        test_aaf_obj.query_interface(obj)
        try:
            obj_type = resolve_closest_class(test_aaf_obj.classdef())
            new_obj = obj_type.__new__(obj_type)
            new_obj.query_interface(obj)
            new_obj.root = obj.root
            return new_obj
        except:
            # print traceback.format_exc()
            # print "no lookup for %s" % test_aaf_obj.class_name
            if isinstance(obj, AAFObject):
                return obj
            else:
                test_aaf_obj.root = obj.root
                return test_aaf_obj

    elif isA(obj, MetaDef):

        if isA(obj, TypeDef):
            new_obj = TypeDef.__new__(TypeDef)
            new_obj.query_interface(obj)
            new_obj.root = obj.root
            return resolve_typedef(new_obj)
        elif isA(obj, ClassDef):
            new_obj = ClassDef.__new__(ClassDef)
            new_obj.query_interface(obj)
            new_obj.root = obj.root
            return new_obj
        elif isA(obj, PropertyDef):
            new_obj = PropertyDef.__new__(PropertyDef)
            new_obj.query_interface(obj)
            new_obj.root = obj.root
            return new_obj
        else:
            raise ValueError("Unknown Metadef")
    return obj

# set the resolve object function
set_resolve_object_func(resolve_object_func)

include "define/MetaDef.pyx"
include "define/ClassDef.pyx"
include "define/PropertyDef.pyx"
include "define/TypeDef.pyx"
include "define/TypeDefCharacter.pyx"
include "define/TypeDefEnum.pyx"
include "define/TypeDefExtEnum.pyx"
include "define/TypeDefFixedArray.pyx"
include "define/TypeDefInt.pyx"

# Note Opaque inherits TypeDefIndirect
include "define/TypeDefIndirect.pyx"
include "define/TypeDefOpaque.pyx"

# Note TypeDefWeakObjRef and TypeDefWeakObjRef inherit
include "define/TypeDefObjectRef.pyx"
include "define/TypeDefStrongObjRef.pyx"
include "define/TypeDefWeakObjRef.pyx"

include "define/TypeDefRecord.pyx"
include "define/TypeDefRename.pyx"
include "define/TypeDefSet.pyx"
include "define/TypeDefStream.pyx"
include "define/TypeDefString.pyx"
include "define/TypeDefVariableArray.pyx"

cdef object resolve_typedef(TypeDef typedef):

    cat = typedef.category
    cdef TypeDef obj

    if cat == lib.kAAFTypeCatInt:
        obj = TypeDefInt.__new__(TypeDefInt)
    elif cat == lib.kAAFTypeCatCharacter:
        obj = TypeDefCharacter.__new__(TypeDefCharacter)
    elif cat == lib.kAAFTypeCatStrongObjRef:
        obj = TypeDefStrongObjRef.__new__(TypeDefStrongObjRef)
    elif cat == lib.kAAFTypeCatWeakObjRef:
        obj = TypeDefWeakObjRef.__new__(TypeDefWeakObjRef)
    elif cat == lib.kAAFTypeCatRename:
        obj = TypeDefRename.__new__(TypeDefRename)
    elif cat == lib.kAAFTypeCatEnum:
        obj = TypeDefEnum.__new__(TypeDefEnum)
    elif cat == lib.kAAFTypeCatFixedArray:
        obj = TypeDefFixedArray.__new__(TypeDefFixedArray)
    elif cat == lib.kAAFTypeCatSet:
        obj = TypeDefSet.__new__(TypeDefSet)
    elif cat == lib.kAAFTypeCatRecord:
        obj = TypeDefRecord.__new__(TypeDefRecord)
    elif cat == lib.kAAFTypeCatStream:
        obj = TypeDefStream.__new__(TypeDefStream)
    elif cat == lib.kAAFTypeCatString:
        obj = TypeDefString.__new__(TypeDefString)
    elif cat == lib.kAAFTypeCatExtEnum:
        obj = TypeDefExtEnum.__new__(TypeDefExtEnum)
    elif cat == lib.kAAFTypeCatIndirect:
        obj = TypeDefIndirect.__new__(TypeDefIndirect)
    elif cat == lib.kAAFTypeCatOpaque:
        obj = TypeDefOpaque.__new__(TypeDefOpaque)
    elif cat == lib.kAAFTypeCatVariableArray:
        obj = TypeDefVariableArray.__new__(TypeDefVariableArray)
    else:
        raise Exception("Unkown TypeDef")

    obj.query_interface(typedef)
    obj.root = typedef.root
    return obj

cpdef dict TypeDefMap = {}
cpdef dict DataDefMap = {}
cpdef dict CodecDefMap = {}
cpdef dict ContainerDefMap = {}
cpdef dict CompressionDefMap = {}
cpdef dict ExtEnumDefMap = {}
cpdef dict InterpolationDefMap = {}

cdef register_defs(map[string, lib.aafUID_t] def_map, dict d, replace=[]):
    cdef pair[string, lib.aafUID_t] def_pair
    cdef AUID auid_obj
    for pair in def_map:
        auid_obj = AUID()
        auid_obj.from_auid(pair.second)
        name = pair.first.decode('ascii')
        for n in replace:
            name = name.replace(n, '')
        d[name.lower()] = auid_obj

register_defs(lib.get_typedef_map(), TypeDefMap, ["kAAFTypeID_"])
register_defs(lib.get_datadef_map(), DataDefMap, ["kAAFDataDef_"])
register_defs(lib.get_codecdef_map(), CodecDefMap, ["kAAFCodecDef_",'kAAFCodec'])
register_defs(lib.get_container_def_map(), ContainerDefMap, ["kAAFContainerDef_"])
register_defs(lib.get_compressiondef_map(), CompressionDefMap, ["kAAFCompressionDef_"])
register_defs(lib.get_extenumdef_map(), ExtEnumDefMap, ["kAAF"])
register_defs(lib.get_interpolationdef_map(), InterpolationDefMap, ["kAAFInterpolationDef_"])

cpdef dict EdgeTypeMap = {"null" : lib.kAAFEtNull,
                          "keycode" : lib.kAAFEtKeycode,
                          "edgenum4" : lib.kAAFEtEdgenum4,
                          "edgenum5" : lib.kAAFEtHeaderSize}

cpdef dict FilmTypeMap = {"null": lib.kAAFFtNull,
                          "35mm" : lib.kAAFFt35MM,
                          "16mm" : lib.kAAFFt16MM,
                          "8mm" : lib.kAAFFt8MM,
                          "65mm" : lib.kAAFFt65MM}

cpdef dict PullDownKindMap = {'twothreepd' : lib.kAAFTwoThreePD,
                              'palpd': lib.kAAFPALPD,
                              'onetotonentsc' : lib.kAAFOneToOneNTSC,
                              'onetoonepal' : lib.kAAFOneToOnePAL,
                              'videotapntsc' : lib.kAAFVideoTapNTSC,
                              'onetoonehdsixty' : lib.kAAFOneToOneHDSixty,
                              'twentyfourtosixtypd' : lib.kAAFTwentyFourToSixtyPD,
                              'twotoonepd' : lib.kAAFTwoToOnePD}

cpdef dict PulldownDirMap = {'tapetofilmspeed' : lib.kAAFTapeToFilmSpeed,
                             'filmtotapespeed' : lib.kAAFFilmToTapeSpeed}

include "define/DefObject.pyx"
include "define/DataDef.pyx"
include "define/ParameterDef.pyx"
include "define/PluginDef.pyx"
include "define/CodecDef.pyx"
include "define/ContainerDef.pyx"
include "define/InterpolationDef.pyx"
include "define/OperationDef.pyx"
include "define/KLVDataDef.pyx"
include "define/TaggedValueDef.pyx"

register_object(DefObject)
register_object(DataDef)
register_object(ParameterDef)
register_object(PluginDef)
register_object(CodecDef)
register_object(ContainerDef)
register_object(InterpolationDef)
register_object(OperationDef)
register_object(KLVDataDef)
register_object(TaggedValueDef)
