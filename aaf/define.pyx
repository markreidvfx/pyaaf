
cimport lib
from .base cimport AAFBase, AAFObject, AUID
from .util cimport error_check, query_interface, aaf_integral, register_object, lookup_object, set_resolve_object_func, MobID
from .property cimport PropertyValue

cimport iterator
from .iterator cimport PropertyDefsIter

from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.pair cimport pair
from libcpp.map cimport map
from wstring cimport  wstring, wideToString

import traceback
import array
from fraction_util import AAFFraction

cdef object isA(AAFBase obj1,obj2):
    try:
        obj2(obj1)
    except:
        return False
    
    return True

def resolve_object_func(AAFBase obj):
    """
    resolve any AAFBase object into it highest level class
    """
    if isA(obj, AAFObject):
        
        AAFObj = AAFObject(obj)
        try:
            obj_type = lookup_object(AAFObj.class_name)
        
            return obj_type(AAFObj)
        except:
            #print traceback.format_exc()
            #print "no lookup for %s" % AAFObj.class_name
            if isinstance(obj, AAFObject):
                return obj
            else:
                return AAFObj
    elif isA(obj, MetaDef):
        
        if isA(obj, TypeDef):
            return resolve_typedef(TypeDef(obj))
        elif isA(obj, ClassDef):
            return ClassDef(obj)
        elif isA(obj, PropertyDef):
            return PropertyDef(obj)
        else:        
            raise ValueError("Unknown Metadef")
    return obj

# set the resolve object function
set_resolve_object_func(resolve_object_func)

cdef class MetaDef(AAFBase):
    def __init__(self, AAFBase obj = None):
        super(MetaDef, self).__init__(obj)
        self.meta_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.meta_ptr, lib.IID_IAAFMetaDefinition)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.meta_ptr
    
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
            pass
    
    property auid:
        def __get__(self):
            cdef AUID auid = AUID()
            error_check(self.meta_ptr.GetAUID(&auid.auid))
            return auid
        
cdef class ClassDef(MetaDef):
    def __init__(self, AAFBase obj = None):
        super(ClassDef, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFClassDef)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def propertydefs(self):
        cdef PropertyDefsIter propdefs_iter = PropertyDefsIter()
        error_check(self.ptr.GetPropertyDefs(&propdefs_iter.ptr))
        return propdefs_iter
    
cdef class PropertyDef(MetaDef):
    def __init__(self, AAFBase obj = None):
        super(PropertyDef, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFPropertyDef)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

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
    def __init__(self, AAFBase obj = None):
        super(TypeDef, self).__init__(obj)
        self.typedef_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.typedef_ptr, lib.IID_IAAFTypeDef)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.typedef_ptr
    
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
    def __init__(self, AAFBase obj = None):
        super(TypeDefCharacter, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefCharacter)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class TypeDefEnum(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefEnum, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefEnum)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def size(self):
        cdef lib.aafUInt32 count
        error_check(self.ptr.CountElements(&count))
        return count
    
    def element_typedef(self):
        cdef TypeDef typedef = TypeDef()
        error_check(self.ptr.GetElementType(&typedef.typedef_ptr))
        return resolve_typedef(TypeDef(typedef))
    
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
    def __init__(self, AAFBase obj = None):
        super(TypeDefExtEnum, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefExtEnum)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
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
    def __init__(self, AAFBase obj = None):
        super(TypeDefFixedArray, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefFixedArray)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def iter_property_value(self, PropertyValue p_value):
        cdef iterator.PropValueIter prop_iter = iterator.PropValueIter()
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        return prop_iter
    
    def value(self, PropertyValue p_value):
        cdef iterator.PropValueResolveIter prop_iter = iterator.PropValueResolveIter()
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        return prop_iter

cdef class TypeDefIndirect(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefIndirect, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefIndirect)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def value(self, PropertyValue p_value):
        cdef PropertyValue out_value = PropertyValue()
        
        error_check(self.ptr.GetActualValue(p_value.ptr, &out_value.ptr))
        
        out_value = PropertyValue(out_value)
        value =  out_value.value
        if value is None:
            raise NotImplementedError("typedef rename of value type %s not implemented" % str(out_value.typedef()))
        return value
    
# Note Opaque inherits TypeDefIndirect
cdef class TypeDefOpaque(TypeDefIndirect):
    def __init__(self, AAFBase obj = None):
        super(TypeDefOpaque, self).__init__(obj)
        self.opaque_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.opaque_ptr, lib.IID_IAAFTypeDefOpaque)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.opaque_ptr
    
    def __dealloc__(self):
        if self.opaque_ptr:
            self.opaque_ptr.Release()
    

cdef class TypeDefInt(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefInt, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefInt)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
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
    def __init__(self, AAFBase obj = None):
        super(TypeDefObjectRef, self).__init__(obj)
        self.ref_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ref_ptr, lib.IID_IAAFTypeDefObjectRef)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ref_ptr
    
    def __dealloc__(self):
        if self.ref_ptr:
            self.ref_ptr.Release()
    
    def object_type(self):
        cdef ClassDef class_def = ClassDef()
        error_check(self.ref_ptr.GetObjectType(&class_def.ptr))
        return ClassDef(class_def)
    
    def value(self, PropertyValue p_value ):
        cdef AAFBase obj = AAFBase()
        error_check(self.ref_ptr.GetObject(p_value.ptr, lib.IID_IUnknown, &obj.base_ptr))
        
        return obj.resolve()

    
    
cdef class TypeDefStrongObjRef(TypeDefObjectRef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefStrongObjRef, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefStrongObjRef)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
cdef class TypeDefWeakObjRef(TypeDefObjectRef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefWeakObjRef, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefWeakObjRef)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class TypeDefRecord(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefRecord, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefRecord)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
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
        cdef TypeDef typedef = TypeDef()
        
        error_check(self.ptr.GetMemberType(index, &typedef.typedef_ptr))
        
        return TypeDef(typedef)
        
    
    def member_value(self, PropertyValue p_value, lib.aafUInt32 index):
        cdef PropertyValue member_value = PropertyValue()
        
        error_check(self.ptr.GetValue(p_value.ptr,
                                       index,
                                       &member_value.ptr
                                       ))
        return PropertyValue(member_value)
    
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
    def __init__(self, AAFBase obj = None):
        super(TypeDefRename, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefRename)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def resolve_rename(self, PropertyValue p_value):
        cdef PropertyValue out_value = PropertyValue()
        error_check(self.ptr.GetBaseValue(p_value.ptr, &out_value.ptr))
        return PropertyValue(out_value)
            
    def set_value(self, PropertyValue p_value, value):        
        self.resolve_rename(p_value).value = value

            
    def value(self, PropertyValue p_value):
        cdef PropertyValue out_value = self.resolve_rename(p_value)
        
        value =  out_value.value
        if value is None:
            raise NotImplementedError("typedef rename of value type %s not implemented" % str(out_value.typedef()))
        return value
        

cdef class TypeDefSet(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefSet, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefSet)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def iter_property_value(self, PropertyValue p_value):
        cdef iterator.PropValueIter prop_iter = iterator.PropValueIter()
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        return prop_iter
    
    def value(self, PropertyValue p_value):
        cdef iterator.PropValueResolveIter prop_iter = iterator.PropValueResolveIter()
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        return prop_iter

cdef class TypeDefStream(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefStream, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefStream)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
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
            
    def value(self,PropertyValue p_value):
        """
        Note this might be slow and use alot of memory
        """
        cdef lib.aafUInt32 sizeInBytes = self.size(p_value)
        
        
        cdef int sizeInChars = (sizeInBytes / sizeof(lib.UChar)) + 1
        
        cdef vector[lib.UChar] buf = vector[lib.UChar](sizeInChars)
        cdef lib.aafUInt32 bytes_read
        
        error_check(self.ptr.Read(p_value.ptr,
                                  sizeInBytes,
                                  <lib.aafMemPtr_t> &buf[0],
                                  &bytes_read
                                  ))
        return array.array("B",buf).tostring()

cdef class TypeDefString(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefString, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefString)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def value(self, PropertyValue p_value ):
        
        cdef lib.aafUInt32 sizeInChars
        cdef int sizeInBytes
        
        error_check(self.ptr.GetCount(p_value.ptr, &sizeInChars))
        sizeInBytes = sizeof(lib.aafCharacter)*sizeInChars
        
        cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter]( sizeInChars )
        
        error_check(self.ptr.GetElements(p_value.ptr,
                                         <lib.aafMemPtr_t> &buf[0],
                                         sizeInBytes))
        
        cdef wstring value = wstring(&buf[0])
        return wideToString(value)

cdef class TypeDefVariableArray(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefVariableArray, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefVariableArray)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def type(self):
        cdef TypeDef typedef = TypeDef()
        error_check(self.ptr.GetType(&typedef.typedef_ptr))
        return TypeDef(typedef)
    
    def size(self,PropertyValue p_value):
        cdef lib.aafUInt32 count
        error_check(self.ptr.GetCount(p_value.ptr, &count))
        return count
    
    def iter_property_value(self, PropertyValue p_value):
        cdef iterator.PropValueIter prop_iter = iterator.PropValueIter()
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        return prop_iter
    
    def value(self, PropertyValue p_value):
        cdef iterator.PropValueResolveIter prop_iter = iterator.PropValueResolveIter()
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        return prop_iter

cdef object resolve_typedef(TypeDef typedef):
    
    cat = typedef.category
    
    if cat == lib.kAAFTypeCatInt:
        return TypeDefInt(typedef)
    elif cat == lib.kAAFTypeCatCharacter:
        return TypeDefCharacter(typedef)
    elif cat == lib.kAAFTypeCatStrongObjRef:
        return TypeDefStrongObjRef(typedef)
    elif cat == lib.kAAFTypeCatWeakObjRef:
        return TypeDefWeakObjRef(typedef)
    elif cat == lib.kAAFTypeCatRename:
        return TypeDefRename(typedef)
    elif cat == lib.kAAFTypeCatEnum:
        return TypeDefEnum(typedef)
    elif cat == lib.kAAFTypeCatFixedArray:
        return TypeDefFixedArray(typedef)
    elif cat == lib.kAAFTypeCatSet:
        return TypeDefSet(typedef)
    elif cat == lib.kAAFTypeCatRecord:
        return TypeDefRecord(typedef)
    elif cat == lib.kAAFTypeCatStream:
        return TypeDefStream(typedef)
    elif cat == lib.kAAFTypeCatString:
        return TypeDefString(typedef)
    elif cat == lib.kAAFTypeCatExtEnum:
        return TypeDefExtEnum(typedef)
    elif cat == lib.kAAFTypeCatIndirect:
        return TypeDefIndirect(typedef)
    elif cat == lib.kAAFTypeCatOpaque:
        return TypeDefOpaque(typedef)
    elif cat == lib.kAAFTypeCatVariableArray:
        return TypeDefVariableArray(typedef)
    else:
        raise Exception("Unkown TypeDef")
    
cpdef dict DataDefMap = {}
cpdef dict CodecDefMap = {}
cpdef dict ContainerDefMap = {}
cpdef dict CompressionDefMap = {}


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

cdef class DefObject(AAFObject):
    def __init__(self, AAFBase obj = None):
        super(DefObject, self).__init__(obj)
        self.iid = lib.IID_IAAFDefObject
        self.auid = lib.AUID_AAFDefObject
        self.defobject_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.defobject_ptr, self.iid)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.defobject_ptr
    
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
    def __init__(self, AAFBase obj = None):
        super(DataDef, self).__init__(obj)
        self.iid = lib.IID_IAAFDataDef
        self.auid = lib.AUID_AAFDataDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def initialize(self, object def_type, bytes):
        pass
    
cdef class ParameterDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(ParameterDef, self).__init__(obj)
        self.iid = lib.IID_IAAFParameterDef
        self.auid = lib.AUID_AAFParameterDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class PluginDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(PluginDef, self).__init__(obj)
        self.iid = lib.IID_IAAFPluginDef
        self.auid = lib.AUID_AAFPluginDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class CodecDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(CodecDef, self).__init__(obj)
        self.iid = lib.IID_IAAFCodecDef
        self.auid = lib.AUID_AAFCodecDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class ContainerDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(ContainerDef, self).__init__(obj)
        self.iid = lib.IID_IAAFContainerDef
        self.auid = lib.AUID_AAFContainerDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class InterpolationDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(InterpolationDef, self).__init__(obj)
        self.iid = lib.IID_IAAFInterpolationDef
        self.auid = lib.AUID_AAFInterpolationDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class OperationDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(OperationDef, self).__init__(obj)
        self.iid = lib.IID_IAAFOperationDef
        self.auid = lib.AUID_AAFOperationDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class KLVDataDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(KLVDataDef, self).__init__(obj)
        self.iid = lib.IID_IAAFKLVDataDefinition
        self.auid = lib.AUID_AAFKLVDataDefinition
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class TaggedValueDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(TaggedValueDef, self).__init__(obj)
        self.iid = lib.IID_IAAFTaggedValueDefinition
        self.auid = lib.AUID_AAFTaggedValueDefinition
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
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