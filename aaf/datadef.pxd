cimport lib

from .base cimport AAFObject


cpdef dict DataDefMap
cpdef dict CodecDefMap
cpdef dict ContainerDefMap

cdef class DefObject(AAFObject):
    cdef lib.IAAFDefObject *defobject_ptr
    
cdef class DataDef(DefObject):
    cdef lib.IAAFDataDef *ptr
    
cdef class ContainerDef(DefObject):
    pass
    
cdef class InterpolationDef(DefObject):
    pass
    
cdef class ParameterDef(DefObject):
    pass
    
cdef class PluginDef(DefObject):
    pass
    
cdef class CodecDef(DefObject):
    pass
    
cdef class OperationDef(DefObject):
    pass
    
cdef class KLVDataDef(DefObject):
    pass
    
cdef class TaggedValueDef(DefObject):
    pass