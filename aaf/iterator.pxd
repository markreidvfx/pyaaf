
cimport lib

cdef class BaseIterator(object):
    pass
    
cdef class ClassDefIter(BaseIterator):
    pass
    
cdef class CodecDefIter(BaseIterator):
    pass
    
cdef class CodecFlavourIter(BaseIterator):
    pass
    
cdef class ComponentIter(BaseIterator):
    cdef lib.IEnumAAFComponents *ptr
    
cdef class ContainerDefIter(BaseIterator):
    pass
    
cdef class ControlPointIter(BaseIterator):
    pass
    
cdef class DataDefIter(BaseIterator):
    pass
    
cdef class EssenceDataIter(BaseIterator):
    pass
    
cdef class FileDescriptorIter(BaseIterator):
    pass
    
cdef class FileEncodingIter(BaseIterator):
    pass
    
cdef class IdentificationIter(BaseIterator):
    pass
    
cdef class InterpolationDefIter(BaseIterator):
    pass
    
cdef class KLVDataIter(BaseIterator):
    pass
    
cdef class KLVDataDefIter(BaseIterator):
    pass
    
cdef class LoadedPluginIter(BaseIterator):
    pass
    
cdef class LocatorIter(BaseIterator):
    pass
    
cdef class MobSlotIter(BaseIterator):
    cdef lib.IEnumAAFMobSlots *ptr
    
cdef class MobIter(BaseIterator):
    cdef lib.IEnumAAFMobs *ptr
    
cdef class OperationDefIter(BaseIterator):
    pass
    
cdef class ParamDefIter(BaseIterator):
    pass
    
cdef class ParamIter(BaseIterator):
    pass
    
cdef class PluginDefIter(BaseIterator):
    pass
    
cdef class PluginLocatorIter(BaseIterator):
    pass
    
cdef class PropIter(BaseIterator):
    cdef lib.IEnumAAFProperties *ptr 
     
cdef class PropertyDefsIter(BaseIterator):
    pass
    
cdef class PropValueIter(BaseIterator):
    cdef lib.IEnumAAFPropertyValues *ptr  
    
cdef class RIFFChunkIter(BaseIterator):
    pass
    
cdef class SegmentIter(BaseIterator):
    pass
    
cdef class TaggedValueDefIter(BaseIterator):
    pass
    
cdef class TaggedValueIter(BaseIterator):
    pass
    
cdef class TypeDefIter(BaseIterator):
    pass
    

    