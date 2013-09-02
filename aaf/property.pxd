cimport lib
from .base cimport AAFBase, AAFObject

cdef class Property(AAFBase):
    cdef lib.IAAFProperty *ptr
    
cdef class PropertyValue(AAFBase):
    cdef lib.IAAFPropertyValue *ptr
    
cdef class TaggedValue(AAFObject):
    cdef lib.IAAFTaggedValue *ptr