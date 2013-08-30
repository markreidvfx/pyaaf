cimport lib
from .base cimport AAFBase

cdef class Property(AAFBase):
    cdef lib.IAAFProperty *ptr
    
cdef class PropertyValue(AAFBase):
    cdef lib.IAAFPropertyValue *ptr