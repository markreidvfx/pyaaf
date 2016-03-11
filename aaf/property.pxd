cimport lib
from .base cimport AAFBase, AAFObject
from .define cimport PropertyDef

cdef class Property(AAFBase):
    cdef lib.IAAFProperty *ptr

cdef class PropertyValue(AAFBase):
    cdef lib.IAAFPropertyValue *ptr

cdef class PropertyItem(AAFBase):
    cdef Property prop
    cdef AAFObject parent
    cdef readonly PropertyDef property_def

cdef class TaggedValue(AAFObject):
    cdef lib.IAAFTaggedValue *ptr
