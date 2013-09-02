cimport lib
from .util cimport error_check, query_interface, register_object

from .define cimport PropertyDef, TypeDef,resolve_typedef

from libcpp.vector cimport vector
from libcpp.string cimport string
from wstring cimport  wstring, wideToString 

cdef class Property(AAFBase):
    def __init__(self, AAFBase obj = None):
        super(Property, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFProperty)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def property_def(self):
        cdef PropertyDef prop_def = PropertyDef()
        error_check(self.ptr.GetDefinition(&prop_def.ptr))
        return PropertyDef(prop_def)
    
    def property_value(self):
        """
        returns PropertyValue object
        """
        cdef PropertyValue value = PropertyValue()
        error_check(self.ptr.GetValue(&value.ptr))
        return PropertyValue(value)
    
    def value_typedef(self):
        value = self.property_value()
        return value.typedef()
    
    property name:
        def __get__(self):
            d = self.property_def()
            return d.name
    property value:
        def __get__(self):
            return self.property_value().value

            
    
cdef class PropertyValue(AAFBase):
    def __init__(self, AAFBase obj = None):
        super(PropertyValue, self).__init__(obj)
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFPropertyValue)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def typedef(self):
        cdef TypeDef type_def = TypeDef()
        error_check(self.ptr.GetType(&type_def.typedef_ptr))
        return resolve_typedef(TypeDef(type_def))
    
    property value:
        def __get__(self):
            typedef = self.typedef()
            return typedef.value(self)
        
cdef class TaggedValue(AAFObject):
    def __init__(self, AAFBase obj = None):
        super(TaggedValue, self).__init__(obj)
        self.iid = lib.IID_IAAFTaggedValue
        self.auid = lib.AUID_AAFTaggedValue
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

register_object(TaggedValue)
        