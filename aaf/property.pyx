cimport lib
from .util cimport error_check, query_interface, register_object

from .define cimport PropertyDef, TypeDef,resolve_typedef, TypeDefString

from libcpp.vector cimport vector
from libcpp.string cimport string
from wstring cimport  wstring, wideToString, toWideString

cdef class PropertyItem(AAFBase):

    def __init__(self, AAFBase obj = None):
        raise TypeError("This class cannot be instantiated from Python")
    
    def property_value(self):
        cdef lib.aafBoolean_t b
        cdef PropertyValue value
            
        error_check(self.parent.obj_ptr.IsPropertyPresent(self.property_def.ptr, &b))
        if b:
            value = PropertyValue.__new__(PropertyValue)
            error_check(self.parent.obj_ptr.GetPropertyValue(self.property_def.ptr, &value.ptr))
            value.query_interface()
            value.root = self.root
            return value
        else:
            return None
    
    property value:
        def __get__(self):

            cdef lib.aafBoolean_t b
            cdef PropertyValue value
            
            error_check(self.parent.obj_ptr.IsPropertyPresent(self.property_def.ptr, &b))
            
            if b:
                value = PropertyValue.__new__(PropertyValue)
                error_check(self.parent.obj_ptr.GetPropertyValue(self.property_def.ptr, &value.ptr))
                value.query_interface()
                return value.value
            
            else:
                return None

        def __set__(self, value):
            cdef lib.aafBoolean_t b
            cdef PropertyValue p_value
            
            error_check(self.parent.obj_ptr.IsPropertyPresent(self.property_def.ptr, &b))
            
            if b:
                p_value = PropertyValue.__new__(PropertyValue)
                error_check(self.parent.obj_ptr.GetPropertyValue(self.property_def.ptr, &p_value.ptr))
                
            else:
                p_value = PropertyValue.__new__(PropertyValue)
                error_check(self.parent.obj_ptr.CreateOptionalPropertyValue(self.property_def.ptr, &p_value.ptr))
                
            p_value.query_interface()
            p_value.value = value 

            error_check(self.parent.obj_ptr.SetPropertyValue(self.property_def.ptr, p_value.ptr))
            
    property typedef:
        def __get__(self):
            return self.property_def.typedef()
    
    property name:
        def __get__(self):
            return self.property_def.name
    
    def __repr__(self):
        return '<%s.%s %s at 0x%x>' % (
                self.__class__.__module__,
                self.__class__.__name__,
                str(self.name), 
                id(self),
                )
                        
cdef class Property(AAFBase):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFProperty
        
    def __init__(self, AAFBase obj = None):
        raise TypeError("This class cannot be instantiated from Python")
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFProperty)
            
        AAFBase.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def property_def(self):
        cdef PropertyDef prop_def = PropertyDef.__new__(PropertyDef)
        error_check(self.ptr.GetDefinition(&prop_def.ptr))
        prop_def.query_interface()
        prop_def.root = self.root
        return prop_def
    
    def property_value(self):
        """
        returns PropertyValue object
        """
        cdef PropertyValue value = PropertyValue.__new__(PropertyValue)
        error_check(self.ptr.GetValue(&value.ptr))
        value.query_interface()
        value.root = self.root
        return value
    
    def value_typedef(self):
        value = self.property_value()
        return value.typedef()
    
    def __repr__(self):
        return '<%s.%s %s at 0x%x>' % (
                self.__class__.__module__,
                self.__class__.__name__,
                str(self.name), 
                id(self),
                )
    
    property name:
        def __get__(self):
            d = self.property_def()
            return d.name
    property value:
        def __get__(self):
            return self.property_value().value
        def __set__(self, value):
            self.property_value().value = value

            
    
cdef class PropertyValue(AAFBase):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFPropertyValue
        
    def __init__(self, AAFBase obj = None):
        raise TypeError("This class cannot be instantiated from Python")
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFPropertyValue)
            
        AAFBase.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def typedef(self):
        cdef TypeDef type_def = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetType(&type_def.typedef_ptr))
        type_def.query_interface()
        type_def.root = self.root
        return resolve_typedef(type_def)
    
    property value:
        def __get__(self):
            typedef = self.typedef()
            return typedef.value(self)
        
        def __set__(self, value):
            typedef = self.typedef()
            typedef.set_value(self, value)
        
cdef class TaggedValue(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTaggedValue
        self.auid = lib.AUID_AAFTaggedValue
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTaggedValue)
            
        AAFObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def typedef(self):
        cdef TypeDef type_def = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetTypeDefinition(&type_def.typedef_ptr))
        type_def.query_interface()
        type_def.root = self.root
        return resolve_typedef(type_def)
            
    property value:
        def __get__(self):
            return self['Value']
        def __set__(self, value):
            typedef = self.typedef()
            if isinstance(typedef, TypeDefString):
                set_tag_bytes(self, value)
                return
            
            raise NotImplementedError("set not implemented for %s", str(typedef))
            
cdef object set_tag_bytes(TaggedValue tag, bytes value):
    cdef wstring w_value = toWideString(value)
    cdef lib.aafUInt32 size_in_bytes = len(value) * sizeof(lib.aafCharacter)
    error_check(tag.ptr.SetValue(size_in_bytes,<lib.aafDataBuffer_t> w_value.c_str()))

register_object(TaggedValue)
        