cimport lib

from .base cimport AAFObject


cpdef dict DataDefMap
cpdef dict CodecDefMap
cpdef dict ContainerDefMap

cdef class DefObject(AAFObject):
    cdef lib.IAAFDefObject *defobject_ptr
    
    
cdef class DataDef(DefObject):
    cdef lib.IAAFDataDef *ptr