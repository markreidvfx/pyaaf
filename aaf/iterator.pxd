
cimport lib

from .base cimport AAFBase, AAFObject
from .define cimport TypeDefStream
from .property cimport PropertyValue

cdef class BaseIterator(object):
    cdef readonly object root
    cdef readonly object _clone_iter

cdef class ClassDefIter(BaseIterator):
    cdef lib.IEnumAAFClassDefs *ptr

cdef class CodecDefIter(BaseIterator):
    cdef lib.IEnumAAFCodecDefs *ptr

cdef class CodecFlavourIter(BaseIterator):
    pass

cdef class ComponentIter(BaseIterator):
    cdef lib.IEnumAAFComponents *ptr

cdef class ContainerDefIter(BaseIterator):
    pass

cdef class ControlPointIter(BaseIterator):
    cdef lib.IEnumAAFControlPoints *ptr

cdef class DataDefIter(BaseIterator):
    pass

cdef class EssenceDataIter(BaseIterator):
    cdef lib.IEnumAAFEssenceData *ptr

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
    cdef lib.IEnumAAFKLVDataDefs *ptr

cdef class LoadedPluginIter(BaseIterator):
    cdef lib.IEnumAAFLoadedPlugins *ptr

cdef class LocatorIter(BaseIterator):
    cdef lib.IEnumAAFLocators *ptr

cdef class MobSlotIter(BaseIterator):
    cdef lib.IEnumAAFMobSlots *ptr

cdef class MobIter(BaseIterator):
    cdef lib.IEnumAAFMobs *ptr

cdef class OperationDefIter(BaseIterator):
    pass

cdef class ParamDefIter(BaseIterator):
    pass

cdef class ParamIter(BaseIterator):
    cdef lib.IEnumAAFParameters* ptr

cdef class PluginDefIter(BaseIterator):
    cdef lib.IEnumAAFPluginDefs* ptr

cdef class PluginLocatorIter(BaseIterator):
    pass

cdef class PropIter(BaseIterator):
    cdef lib.IEnumAAFProperties *ptr

cdef class PropItemIter(BaseIterator):
    cdef lib.IEnumAAFProperties *ptr
    cdef AAFObject parent

cdef class PropertyDefsIter(BaseIterator):
    cdef lib.IEnumAAFPropertyDefs *ptr

cdef class PropValueIter(BaseIterator):
    cdef lib.IEnumAAFPropertyValues *ptr

cdef class PropValueResolveIter(BaseIterator):
    cdef lib.IEnumAAFPropertyValues *ptr

cdef class RIFFChunkIter(BaseIterator):
    pass

cdef class SegmentIter(BaseIterator):
    cdef lib.IEnumAAFSegments *ptr

cdef class TaggedValueDefIter(BaseIterator):
    pass

cdef class TaggedValueIter(BaseIterator):
    cdef lib.IEnumAAFTaggedValues *ptr

cdef class TypeDefIter(BaseIterator):
    cdef lib.IEnumAAFTypeDefs *ptr

cdef class TypeDefStreamDataIter(BaseIterator):
    cdef TypeDefStream stream_typedef
    cdef PropertyValue value
    cdef public lib.aafUInt32 readsize
