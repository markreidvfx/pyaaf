
cimport lib
from .base cimport AAFBase, AAFObject
from .util cimport error_check, query_interface, aaf_integral, register_object, lookup_object, set_resolve_object_func, AUID, MobID, WCharBuffer
from .property cimport PropertyValue

from .iterator cimport PropertyDefsIter, TypeDefStreamDataIter, PropValueIter, PropValueResolveIter

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
            obj_type = lookup_object(test_aaf_obj.class_name)
            new_obj = obj_type.__new__(obj_type)
            new_obj.query_interface(obj)
            new_obj.root = obj.root
            return new_obj
        except:
            #print traceback.format_exc()
            #print "no lookup for %s" % AAFObj.class_name
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

cdef class MetaDef(AAFBase):
    def __cinit__(self):
        self.meta_ptr = NULL
        self.iid = lib.IID_IAAFMetaDefinition
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.meta_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.meta_ptr, lib.IID_IAAFMetaDefinition)
            
        AAFBase.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.meta_ptr:
            self.meta_ptr.Release()
    
    property name:
        def __get__(self):
            cdef lib.aafUInt32 sizeInBytes = 0
            error_check(self.meta_ptr.GetNameBufLen(&sizeInBytes))
            
            cdef int sizeInChars = (sizeInBytes / sizeof(lib.aafCharacter)) + 1
            cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
            
            error_check(self.meta_ptr.GetName(&buf[0], sizeInChars*sizeof(lib.aafCharacter) ))
            
            cdef wstring name = wstring(&buf[0])
            return wideToString(name)
        
    property description:
        def __get__(self):
            cdef lib.aafUInt32 sizeInBytes = 0
            error_check(self.meta_ptr.GetDescriptionBufLen(&sizeInBytes))
            
            cdef int sizeInChars = (sizeInBytes / sizeof(lib.aafCharacter)) + 1
            cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
            
            error_check(self.meta_ptr.GetDescription(&buf[0], sizeInChars*sizeof(lib.aafCharacter) ))
            
            cdef wstring name = wstring(&buf[0])
            return wideToString(name)
    
    property auid:
        def __get__(self):
            cdef AUID auid = AUID()
            error_check(self.meta_ptr.GetAUID(&auid.auid))
            return auid
        
cdef class ClassDef(MetaDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFClassDef
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFClassDef)
            
        MetaDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def parent(self):
        cdef ClassDef classdef = ClassDef.__new__(ClassDef)
        error_check(self.ptr.GetParent(&classdef.ptr))
        classdef.query_interface()
        classdef.root = self.root
        return classdef
            
    def propertydefs(self):
        cdef PropertyDefsIter propdefs_iter = PropertyDefsIter.__new__(PropertyDefsIter)
        error_check(self.ptr.GetPropertyDefs(&propdefs_iter.ptr))
        propdefs_iter.root = self.root
        return propdefs_iter
    
cdef class PropertyDef(MetaDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFPropertyDef
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFPropertyDef)
            
        MetaDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    property optional:
        def __get__(self):
            cdef lib.aafBoolean_t value
            error_check(self.ptr.GetIsOptional(&value))
            if value:
                return True
            return False

cdef class TypeDef(MetaDef):
    def __cinit__(self):
        self.typedef_ptr = NULL
        self.iid = lib.IID_IAAFTypeDef
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.typedef_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.typedef_ptr, lib.IID_IAAFTypeDef)
            
        MetaDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.typedef_ptr:
            self.typedef_ptr.Release()
    
    def value(self, PropertyValue p_value ):
        raise NotImplementedError("value method not implemented for type %s" %(str(self)))
    
    def set_value(self, PropertyValue p_value, value):
        raise NotImplementedError("set value method not implemented for type %s" %(str(self)))
    
    property category:
        def __get__(self):
            cdef lib.eAAFTypeCategory_t cat
            error_check(self.typedef_ptr.GetTypeCategory(&cat))
            return cat
        
cdef class TypeDefCharacter(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefCharacter
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefCharacter)
            
        TypeDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class TypeDefEnum(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefEnum
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefEnum)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def size(self):
        cdef lib.aafUInt32 count
        error_check(self.ptr.CountElements(&count))
        return count
    
    def element_typedef(self):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetElementType(&typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(typedef)
    
    def element_name(self, lib.aafUInt32 index):
        cdef lib.aafUInt32 sizeInChars
        cdef lib.aafUInt32 sizeInBytes
        
        error_check(self.ptr.GetElementNameBufLen(index, &sizeInBytes))
        sizeInChars = sizeInBytes / sizeof(lib.aafCharacter) + 1
        
        cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
        
        error_check(self.ptr.GetElementName(index,
                                           &buf[0],
                                           sizeInBytes))
        
        cdef wstring value = wstring(&buf[0])
        return wideToString(value)
    
    def element_name_from_value(self, PropertyValue p_value):
        cdef lib.aafUInt32 sizeInChars
        cdef lib.aafUInt32 sizeInBytes
        
        error_check(self.ptr.GetNameBufLenFromValue(p_value.ptr, &sizeInBytes))
        sizeInChars = sizeInBytes / sizeof(lib.aafCharacter) + 1
        
        cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
        
        error_check(self.ptr.GetNameFromValue(p_value.ptr,
                                           &buf[0],
                                           sizeInBytes))
        
        cdef wstring value = wstring(&buf[0])
        return wideToString(value)
    
    def element_value(self, lib.aafUInt32 index):
        cdef lib.aafInt64 value
        error_check(self.ptr.GetElementValue(index, &value))
        return value
    
    def elements(self):
        d = {}
        
        for i in xrange(self.size()):
            name =self.element_name(i)
            value = self.element_value(i)
            d[name] = value
        return d
    
    def set_value(self, PropertyValue p_value, bytes value):
        cdef lib.aafInt64 enum_value
        for key,enum_value in self.elements().items():
            if key.lower() == value.lower():
                error_check(self.ptr.SetIntegerValue(p_value.ptr, enum_value))
                return
            
        raise ValueError("Invalid TypeDefEnum Key %s" % value)
    
    def value(self, PropertyValue p_value):
        v = self.element_name_from_value(p_value)
        if v == "True":
            return True
        if v == "False":
            return False
        
        return v

cdef class TypeDefExtEnum(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefExtEnum
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefExtEnum)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def size(self):
        cdef lib.aafUInt32 count
        error_check(self.ptr.CountElements(&count))
        return count
    
    def element_name(self, lib.aafUInt32 index):
        cdef lib.aafUInt32 sizeInChars
        cdef lib.aafUInt32 sizeInBytes
        
        error_check(self.ptr.GetElementNameBufLen(index, &sizeInBytes))
        sizeInChars = sizeInBytes / sizeof(lib.aafCharacter) + 1
        
        cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
        
        error_check(self.ptr.GetElementName(index,
                                           &buf[0],
                                           sizeInBytes))
        
        cdef wstring value = wstring(&buf[0])
        return wideToString(value)
    
    def element_name_from_value(self, PropertyValue p_value):
        cdef lib.aafUInt32 sizeInChars
        cdef lib.aafUInt32 sizeInBytes
        
        error_check(self.ptr.GetNameBufLenFromValue(p_value.ptr, &sizeInBytes))
        sizeInChars = sizeInBytes / sizeof(lib.aafCharacter) + 1
        
        cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
        
        error_check(self.ptr.GetNameFromValue(p_value.ptr,
                                           &buf[0],
                                           sizeInBytes))
        
        cdef wstring value = wstring(&buf[0])
        return wideToString(value)
    
    def element_value(self, lib.aafUInt32 index):

        cdef AUID auid = AUID()
        error_check(self.ptr.GetElementValue(index, &auid.auid))
        return auid
    
    def elements(self):
        d = {}
        for i in xrange(self.size()):
            name =self.element_name(i)
            value = self.element_value(i)
            d[name]= value
        return d
    
    def value(self, PropertyValue p_value):
        return self.element_name_from_value(p_value)

cdef class TypeDefFixedArray(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefFixedArray
        
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefFixedArray)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def iter_property_value(self, PropertyValue p_value):
        cdef PropValueIter prop_iter = PropValueIter.__new__(PropValueIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter
    
    def value(self, PropertyValue p_value):
        cdef PropValueResolveIter prop_iter = PropValueResolveIter.__new__(PropValueResolveIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter

cdef class TypeDefIndirect(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefIndirect
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefIndirect)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def indirect_value(self, PropertyValue p_value):
        cdef PropertyValue out_value = PropertyValue.__new__(PropertyValue)
        error_check(self.ptr.GetActualValue(p_value.ptr, &out_value.ptr))
        out_value.query_interface()
        out_value.root = self.root
        return out_value
    
    def set_value(self, PropertyValue p_value, object value):
        cdef PropertyValue indirect_value = self.indirect_value(p_value)
        indirect_value.value = value
            
    def value(self, PropertyValue p_value):
        cdef PropertyValue out_value = self.indirect_value(p_value)
        value =  out_value.value
        if value is None:
            raise NotImplementedError("typedef rename of value type %s not implemented" % str(out_value.typedef()))
        return value
    
# Note Opaque inherits TypeDefIndirect
cdef class TypeDefOpaque(TypeDefIndirect):
    def __cinit__(self):
        self.opaque_ptr = NULL
        self.iid = lib.IID_IAAFTypeDefOpaque
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.opaque_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.opaque_ptr, lib.IID_IAAFTypeDefOpaque)
            
        TypeDefIndirect.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.opaque_ptr:
            self.opaque_ptr.Release()
    

cdef class TypeDefInt(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefInt
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefInt)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def size(self):
        cdef lib.aafUInt32 size
        error_check(self.ptr.GetSize(&size))
        return size
    
    def is_signed(self):
        cdef lib.aafBoolean_t sign
        error_check(self.ptr.IsSigned(&sign))
        return bool(sign)
    
    def set_value(self, PropertyValue p_value, value):
        
        cdef lib.aafUInt32 size = self.size()
        if self.is_signed():
            if sizeof(lib.aafInt8) == size:
                set_int[lib.aafInt8](self, p_value, value)
            elif sizeof(lib.aafInt16) == size:
                set_int[lib.aafInt16](self, p_value, value)
            elif sizeof(lib.aafInt32) == size:
                set_int[lib.aafInt32](self, p_value, value)
            else:
                set_int[lib.aafInt64](self, p_value, value)
        else:
            if sizeof(lib.aafUInt8) == size:
                set_int[lib.aafUInt8](self, p_value, value)
            elif sizeof(lib.aafUInt16) == size:
                set_int[lib.aafUInt16](self, p_value, value)
            elif sizeof(lib.aafUInt32) == size:
                set_int[lib.aafUInt32](self, p_value, value)
            else:
                set_int[lib.aafUInt64](self, p_value, value)
        if value != self.value(p_value):
            raise ValueError("unable to set value")

    def value(self, PropertyValue p_value ):
        
        cdef lib.aafUInt32 size = self.size()
        if self.is_signed():
            if sizeof(lib.aafInt8) == size:
                return get_int[lib.aafInt8](self, p_value, 0)
            elif sizeof(lib.aafInt16) == size:
                return get_int[lib.aafInt16](self, p_value, 0)
            elif sizeof(lib.aafInt32) == size:
                return get_int[lib.aafInt32](self, p_value, 0)
            else:
                return get_int[lib.aafInt64](self, p_value, 0)
        else:
            if sizeof(lib.aafUInt8) == size:
                return get_int[lib.aafUInt8](self, p_value, 0)
            elif sizeof(lib.aafUInt16) == size:
                return get_int[lib.aafUInt16](self, p_value, 0)
            elif sizeof(lib.aafUInt32) == size:
                return get_int[lib.aafUInt32](self, p_value, 0)
            else:
                return get_int[lib.aafUInt64](self, p_value, 0)
            
cdef aaf_integral get_int(TypeDefInt typdef, PropertyValue value,aaf_integral i):
    error_check(typdef.ptr.GetInteger(value.ptr, 
                                       <lib.aafMemPtr_t>&i, 
                                       sizeof(aaf_integral)))

    return i

cdef aaf_integral set_int(TypeDefInt typdef, PropertyValue value,aaf_integral i):
    error_check(typdef.ptr.SetInteger(value.ptr, 
                                       <lib.aafMemPtr_t>&i, 
                                       sizeof(aaf_integral)))



# Note TypeDefWeakObjRef and TypeDefWeakObjRef inherit
cdef class TypeDefObjectRef(TypeDef):
    def __cinit__(self):
        self.ref_ptr = NULL
        self.iid = lib.IID_IAAFTypeDefObjectRef
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ref_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ref_ptr, lib.IID_IAAFTypeDefObjectRef)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ref_ptr:
            self.ref_ptr.Release()
    
    def object_type(self):
        cdef ClassDef class_def = ClassDef.__new__(ClassDef)
        error_check(self.ref_ptr.GetObjectType(&class_def.ptr))
        class_def.query_interface()
        class_def.root = self.root
        return class_def
    
    def value(self, PropertyValue p_value ):
        cdef AAFBase obj = AAFBase.__new__(AAFBase)
        error_check(self.ref_ptr.GetObject(p_value.ptr, lib.IID_IUnknown, &obj.base_ptr))
        obj.root = self.root
        return obj.resolve()

    
    
cdef class TypeDefStrongObjRef(TypeDefObjectRef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefStrongObjRef
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefStrongObjRef)
            
        TypeDefObjectRef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
cdef class TypeDefWeakObjRef(TypeDefObjectRef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefWeakObjRef
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefWeakObjRef)
            
        TypeDefObjectRef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class TypeDefRecord(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefRecord
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefRecord)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def size(self):
        cdef lib.aafUInt32 count
        error_check(self.ptr.GetCount(&count))
        return count
    
    def member_name(self, lib.aafUInt32 index):
        cdef lib.aafUInt32 sizeInChars
        cdef lib.aafUInt32 sizeInBytes
        
        error_check(self.ptr.GetMemberNameBufLen(index, &sizeInBytes))
        sizeInChars = sizeInBytes / sizeof(lib.aafCharacter) + 1
        
        cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
        
        error_check(self.ptr.GetMemberName(index,
                                           &buf[0],
                                           sizeInBytes))
        
        cdef wstring value = wstring(&buf[0])
        return wideToString(value)
    
    def member_type(self, lib.aafUInt32 index):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        
        error_check(self.ptr.GetMemberType(index, &typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(typedef)
        
    
    def member_value(self, PropertyValue p_value, lib.aafUInt32 index):
        cdef PropertyValue member_value = PropertyValue.__new__(PropertyValue)
        
        error_check(self.ptr.GetValue(p_value.ptr,
                                       index,
                                       &member_value.ptr
                                       ))
        member_value.query_interface()
        member_value.root = self.root
        return member_value
    
    def value(self, PropertyValue p_value):
        value_dict = {}
        
        cdef AUID auid_typdef = AUID()
        auid_typdef.from_auid(lib.kAAFTypeID_AUID)
        
        if self.auid == auid_typdef:
            return auid_from_prop_value(self, p_value)
        
        auid_typdef.from_auid(lib.kAAFTypeID_MobIDType)
        
        if self.auid == auid_typdef:
            return mobid_from_prop_value(self, p_value)
        
        auid_typdef.from_auid(lib.kAAFTypeID_DateStruct)
        
        if self.auid == auid_typdef:
            return get_date(self, p_value)
        
        auid_typdef.from_auid(lib.kAAFTypeID_TimeStruct)
        
        if self.auid == auid_typdef:
            return get_time(self, p_value)
        
        auid_typdef.from_auid(lib.kAAFTypeID_TimeStamp)
        
        if self.auid == auid_typdef:
            return get_timestamp(self, p_value)
        
        auid_typdef.from_auid(lib.kAAFTypeID_Rational)
        
        if self.auid == auid_typdef:
            try:
                return AAFFraction(self.member_value(p_value, 0).value, self.member_value(p_value, 1).value)
            except:
                pass

        for i in xrange(self.size()):
            value_prop = self.member_value(p_value, i)
            value_type = self.member_type(i)
            value_dict[self.member_name(i)] = resolve_typedef(value_type).value(value_prop)
        
        return value_dict
            
cdef object auid_from_prop_value(TypeDefRecord record, PropertyValue value ):
    cdef AUID retAUID = AUID()
    cdef lib.aafUID_t auid
    
    auid.Data1 = record.member_value(value, 0).value
    auid.Data2 = record.member_value(value, 1).value
    auid.Data3 = record.member_value(value, 2).value
    for i,v in  enumerate(record.member_value(value, 3).value):
        auid.Data4[i] = v
    retAUID.auid = auid
    return retAUID

cdef object mobid_from_prop_value(TypeDefRecord record, PropertyValue value):
    cdef MobID mobID_obj = MobID()

    cdef lib.aafMobID_t mobID_t
    
    for i,v in enumerate(record.member_value(value, 0).value):
        mobID_t.SMPTELabel[i] = v
    
    mobID_t.length = record.member_value(value, 1).value
    mobID_t.instanceHigh = record.member_value(value, 2).value
    mobID_t.instanceMid = record.member_value(value, 3).value
    mobID_t.instanceLow = record.member_value(value, 4).value
    
    cdef AUID auid = record.member_value(value, 5).value
    
    mobID_t.material = auid.auid
    
    mobID_obj.mobID = mobID_t
    return mobID_obj
    

cdef object get_time(TypeDefRecord record, PropertyValue value):
    hour = record.member_value(value, 0).value
    minute = record.member_value(value, 1).value
    second = record.member_value(value,2).value
    fraction = record.member_value(value,3).value
    
    return "%02d:%02d:%02d.%02d" % (hour, minute, second, fraction)

cdef object get_date(TypeDefRecord record, PropertyValue value):
    
    year = record.member_value(value, 0).value
    month = record.member_value(value, 1).value
    day = record.member_value(value,2).value
    
    return "%d-%02d-%02d" % (year, month, day)

cdef object get_timestamp(TypeDefRecord record, PropertyValue value):
    
    return "%s %s" % ( record.member_value(value, 0).value, record.member_value(value, 1).value)
    
    
cdef class TypeDefRename(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefRename
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefRename)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def resolve_rename(self, PropertyValue p_value):
        cdef PropertyValue out_value = PropertyValue.__new__(PropertyValue)
        error_check(self.ptr.GetBaseValue(p_value.ptr, &out_value.ptr))
        out_value.query_interface()
        out_value.root = self.root
        return out_value
            
    def set_value(self, PropertyValue p_value, value):        
        self.resolve_rename(p_value).value = value

            
    def value(self, PropertyValue p_value):
        cdef PropertyValue out_value = self.resolve_rename(p_value)
        
        value =  out_value.value
        if value is None:
            raise NotImplementedError("typedef rename of value type %s not implemented" % str(out_value.typedef()))
        return value
        

cdef class TypeDefSet(TypeDef):
    def __cinit__(self):
        self.ptr == NULL
        self.iid = lib.IID_IAAFTypeDefSet
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefSet)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def iter_property_value(self, PropertyValue p_value):
        cdef PropValueIter prop_iter = PropValueIter.__new__(PropValueIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter
    
    def value(self, PropertyValue p_value):
        cdef PropValueResolveIter prop_iter = PropValueResolveIter.__new__(PropValueResolveIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter

cdef class TypeDefStream(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefStream
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefStream)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def size(self, PropertyValue p_value):
        """
        Returns number of bytes contained in the referenced property value
        """
        cdef lib.aafInt64 size
        error_check(self.ptr.GetSize(p_value.ptr, &size))
        return size
    
    def position(self, PropertyValue p_value):
        cdef lib.aafInt64 position
        error_check(self.ptr.GetPosition(p_value.ptr, &position))
        return position
    
    def set_position(self, PropertyValue p_value, lib.aafInt64 position):
        error_check(self.ptr.SetPosition(p_value.ptr, position))
    
    def read(self, PropertyValue p_value, lib.aafUInt32 readsize):
        
        
        readsize = min(readsize, self.size(p_value) - self.position(p_value))
        
        if readsize <= 0:
            return None
        
        cdef vector[lib.UChar] buf = vector[lib.UChar](readsize)
        cdef lib.aafUInt32 bytes_read = 0 
        cdef string s
        hr = self.ptr.Read(p_value.ptr,
                                  readsize,
                                  <lib.aafMemPtr_t> &buf[0],
                                  &bytes_read
                                  )

        error_check(hr)
            
        s = string(<char * > &buf[0], bytes_read)
        return s
         
            
    def value(self,PropertyValue p_value):
        
        cdef TypeDefStreamDataIter data_iter = TypeDefStreamDataIter.__new__(TypeDefStreamDataIter)
        data_iter.stream_typedef = self
        data_iter.value = p_value
        data_iter.root = self.root
        data_iter._clone_iter = lambda v=p_value: self.value(v)
        return data_iter

cdef class TypeDefString(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefString
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefString)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def typedef(self):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetType(&typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(TypeDef(typedef))
            
    def set_value(self, PropertyValue p_value, bytes value):

        cdef WCharBuffer buf = WCharBuffer.__new__(WCharBuffer)
        
        buf.from_string(value)
        
        print len(value), buf.size(), buf.size_in_bytes()

        #cdef lib.aafUInt32 size_in_bytes =  buf.buf.size() * sizeof(lib.aafCharacter)
        error_check(self.ptr.SetCString(p_value.ptr,
                                        <lib.aafMemPtr_t> buf.to_wchar(),
                                        buf.size_in_bytes()))
        
        #print self.value(p_value)
    
    def value(self, PropertyValue p_value ):
        
        cdef lib.aafUInt32 sizeInChars
        cdef int sizeInBytes
        
        error_check(self.ptr.GetCount(p_value.ptr, &sizeInChars))
        sizeInBytes = sizeof(lib.aafCharacter)*sizeInChars
        
        if not sizeInBytes:
            return None
        
        cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter]( sizeInChars )
        
        
        error_check(self.ptr.GetElements(p_value.ptr,
                                         <lib.aafMemPtr_t> &buf[0],
                                         sizeInBytes))
        
        cdef wstring value = wstring(&buf[0])
        return wideToString(value)

cdef class TypeDefVariableArray(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefVariableArray
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefVariableArray)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def type(self):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetType(&typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(typedef)
    
    def size(self,PropertyValue p_value):
        cdef lib.aafUInt32 count
        error_check(self.ptr.GetCount(p_value.ptr, &count))
        return count
    
    def iter_property_value(self, PropertyValue p_value):
        cdef PropValueIter prop_iter = PropValueIter.__new__(PropValueIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter
    
    def value(self, PropertyValue p_value):
        cdef PropValueResolveIter prop_iter = PropValueResolveIter.__new__(PropValueResolveIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter

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
    
cpdef dict DataDefMap = {}
cpdef dict CodecDefMap = {}
cpdef dict ContainerDefMap = {}
cpdef dict CompressionDefMap = {}
cpdef dict ExtEnumDefMap = {}

cdef register_defs(map[string, lib.aafUID_t] def_map, dict d, replace=[]):
    cdef pair[string, lib.aafUID_t] def_pair
    cdef AUID auid_obj 
    for pair in def_map:
        auid_obj = AUID()
        auid_obj.from_auid(pair.second)
        name = pair.first
        for n in replace:
            name = name.replace(n, '')
        d[name.lower()] = auid_obj
    
register_defs(lib.get_datadef_map(), DataDefMap, ["kAAFDataDef_"])
register_defs(lib.get_codecdef_map(), CodecDefMap, ["kAAFCodecDef_",'kAAFCodec'])
register_defs(lib.get_container_def_map(), ContainerDefMap, ["kAAFContainerDef_"])
register_defs(lib.get_compressiondef_map(), CompressionDefMap, ["kAAFCompressionDef_"])
register_defs(lib.get_extenumdef_map(), ExtEnumDefMap, ["kAAF"])

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

cdef class DefObject(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFDefObject
        self.auid = lib.AUID_AAFDefObject
        self.defobject_ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.defobject_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.defobject_ptr, lib.IID_IAAFDefObject)
            
        AAFObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.defobject_ptr:
            self.defobject_ptr.Release()
            
    property name:
        def __get__(self):
            cdef lib.aafUInt32 sizeInBytes = 0
            error_check(self.defobject_ptr.GetNameBufLen(&sizeInBytes))
            
            cdef int sizeInChars = (sizeInBytes / sizeof(lib.aafCharacter)) + 1
            cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
            
            error_check(self.defobject_ptr.GetName(&buf[0], sizeInChars*sizeof(lib.aafCharacter) ))
            
            cdef wstring name = wstring(&buf[0])
            return wideToString(name)
            

cdef class DataDef(DefObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFDataDef
        self.auid = lib.AUID_AAFDataDef
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFDataDef)
            
        DefObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class ParameterDef(DefObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFParameterDef
        self.auid = lib.AUID_AAFParameterDef
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFParameterDef)
            
        DefObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class PluginDef(DefObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFPluginDef
        self.auid = lib.AUID_AAFPluginDef
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFPluginDef)
            
        DefObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class CodecDef(DefObject):
    def __cinit_(self):
        self.iid = lib.IID_IAAFCodecDef
        self.auid = lib.AUID_AAFCodecDef
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFCodecDef)
            
        DefObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class ContainerDef(DefObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFContainerDef
        self.auid = lib.AUID_AAFContainerDef
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFContainerDef)
            
        DefObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class InterpolationDef(DefObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFInterpolationDef
        self.auid = lib.AUID_AAFInterpolationDef
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFInterpolationDef)
            
        DefObject.query_interface(self, obj)
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class OperationDef(DefObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFOperationDef
        self.auid = lib.AUID_AAFOperationDef
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFOperationDef)
            
        DefObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class KLVDataDef(DefObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFKLVDataDefinition
        self.auid = lib.AUID_AAFKLVDataDefinition
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFKLVDataDefinition)
            
        DefObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class TaggedValueDef(DefObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTaggedValueDefinition
        self.auid = lib.AUID_AAFTaggedValueDefinition
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTaggedValueDefinition)
            
        DefObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

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