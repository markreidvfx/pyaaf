cimport lib

from .base cimport AAFObject,AAFBase


cdef class EssenceFormat(AAFBase):
    cdef lib.IAAFEssenceFormat *ptr

cdef class EssenceMultiAccess(AAFBase):
    cdef lib.IAAFEssenceMultiAccess *essence_ptr

cdef class EssenceAccess(EssenceMultiAccess):
    cdef lib.IAAFEssenceAccess *ptr

cdef class Locator(AAFObject):
    cdef lib.IAAFLocator *loc_ptr
    
cdef class NetworkLocator(Locator):
    cdef lib.IAAFNetworkLocator *ptr
    
cdef class EssenceDescriptor(AAFObject):
    cdef lib.IAAFEssenceDescriptor *essence_ptr

cdef class FileDescriptor(EssenceDescriptor):
    cdef lib.IAAFFileDescriptor *file_ptr
    
cdef class WAVEDescriptor(FileDescriptor):
    cdef lib.IAAFWAVEDescriptor *ptr

cdef class DigitalImageDescriptor(FileDescriptor):
    cdef lib.IAAFDigitalImageDescriptor *im_ptr
    
cdef class CDCIDescriptor(DigitalImageDescriptor):
    cdef lib.IAAFCDCIDescriptor *ptr
    
cdef class RGBADescriptor(DigitalImageDescriptor):
    pass
    
cdef class SoundDescriptor(FileDescriptor):
    pass

cdef class PCMDescriptor(SoundDescriptor):
    pass

cdef class TapeDescriptor(EssenceDescriptor):
    pass
    
cdef class FilmDescriptor(EssenceDescriptor):
    pass
    
cdef class PhysicalDescriptor(EssenceDescriptor):
    pass
    
cdef class ImportDescriptor(PhysicalDescriptor):
    pass
    
cdef class RecordingDescriptor(PhysicalDescriptor):
    pass
    
cdef class AuxiliaryDescriptor(PhysicalDescriptor):
    pass