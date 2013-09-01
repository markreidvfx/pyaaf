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
    cdef lib.IAAFPluginDef *ptr
    
cdef class CodecDef(DefObject):
    cdef lib.IAAFCodecDef *ptr
    
cdef class OperationDef(DefObject):
    cdef lib.IAAFOperationDef *ptr
    
cdef class KLVDataDef(DefObject):
    cdef lib.IAAFKLVDataDefinition *ptr
    
cdef class TaggedValueDef(DefObject):
    pass