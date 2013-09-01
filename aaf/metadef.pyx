
cimport lib
from .util cimport error_check, query_interface, aaf_integral
from .property cimport PropertyValue

cimport iterator

from libcpp.vector cimport vector
from libcpp.string cimport string
from wstring cimport  wstring, wideToString

cdef class MetaDef(AAFBase):
    def __init__(self, AAFBase obj = None):
        super(MetaDef, self).__init__(obj)
        self.meta_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.meta_ptr, lib.IID_IAAFMetaDefinition)
    
    cdef lib.IUnknown **get(self):
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
    
cdef class ClassDef(MetaDef):
    def __init__(self, AAFBase obj = None):
        super(ClassDef, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFClassDef)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
cdef class PropertyDef(MetaDef):
    def __init__(self, AAFBase obj = None):
        super(PropertyDef, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFPropertyDef)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    

cdef class TypeDef(MetaDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDef, self).__init__(obj)
        self.typedef_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.typedef_ptr, lib.IID_IAAFTypeDef)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.typedef_ptr
    
    def __dealloc__(self):
        if self.typedef_ptr:
            self.typedef_ptr.Release()
    
    def value(self, PropertyValue p_value ):
        pass
    
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
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefCharacter)
    
    cdef lib.IUnknown **get(self):
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
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefEnum)
    
    cdef lib.IUnknown **get(self):
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
    
    def value(self, PropertyValue p_value):
        d= {}
        d['name_from_value'] = self.element_name_from_value(p_value)
        
        for i in xrange(self.size()):
            name =self.element_name(i)
            value = self.element_value(i)
            
            d[name] = value
            
        return d
    

cdef class TypeDefExtEnum(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefExtEnum, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefExtEnum)
    
    cdef lib.IUnknown **get(self):
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
        cdef lib.aafUID_t auid
        error_check(self.ptr.GetElementValue(index, &auid))
        return auid
    
    def value(self, PropertyValue p_value):
        d= {}
        d['name_from_value'] = self.element_name_from_value(p_value)
        
        for i in xrange(self.size()):
            name =self.element_name(i)
            value = self.element_value(i)
            
            d[name] = value
            
        return d

cdef class TypeDefFixedArray(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefFixedArray, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefFixedArray)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def value(self, PropertyValue p_value):
        cdef iterator.PropValueIter prop_iter = iterator.PropValueIter()
        
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        
        return prop_iter

cdef class TypeDefIndirect(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefIndirect, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefIndirect)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
# Note Opaque inherits TypeDefIndirect
cdef class TypeDefOpaque(TypeDefIndirect):
    def __init__(self, AAFBase obj = None):
        super(TypeDefOpaque, self).__init__(obj)
        self.opaque_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.opaque_ptr, lib.IID_IAAFTypeDefOpaque)
    
    cdef lib.IUnknown **get(self):
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
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefInt)
    
    cdef lib.IUnknown **get(self):
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

    def value(self, PropertyValue p_value ):
        
        cdef lib.aafUInt32 size = self.size()
        
        if self.is_signed:
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


# Note TypeDefWeakObjRef and TypeDefWeakObjRef inherit
cdef class TypeDefObjectRef(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefObjectRef, self).__init__(obj)
        self.ref_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ref_ptr, lib.IID_IAAFTypeDefObjectRef)
    
    cdef lib.IUnknown **get(self):
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
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefStrongObjRef)
    
    cdef lib.IUnknown **get(self):
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
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefWeakObjRef)
    
    cdef lib.IUnknown **get(self):
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
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefRecord)
    
    cdef lib.IUnknown **get(self):
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
        for i in xrange(self.size()):
            value_prop = self.member_value(p_value, i)
            value_type = self.member_type(i)
            value_dict[self.member_name(i)] = resolve_typedef(value_type).value(value_prop)
        
        return value_dict
            
    
    
cdef class TypeDefRename(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefRename, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefRename)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def value(self, PropertyValue p_value):
        cdef PropertyValue out_value = PropertyValue()
        
        error_check(self.ptr.GetBaseValue(p_value.ptr, &out_value.ptr))
        
        out_value = PropertyValue(out_value)
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
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefSet)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def value(self, PropertyValue p_value):
        cdef iterator.PropValueIter prop_iter = iterator.PropValueIter()
        
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        
        return prop_iter

cdef class TypeDefStream(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefStream, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefStream)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class TypeDefString(TypeDef):
    def __init__(self, AAFBase obj = None):
        super(TypeDefString, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefString)
    
    cdef lib.IUnknown **get(self):
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
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefVariableArray)
    
    cdef lib.IUnknown **get(self):
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
    
    def value(self, PropertyValue p_value):
        cdef iterator.PropValueIter prop_iter = iterator.PropValueIter()
        
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