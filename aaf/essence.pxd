cimport lib

from .base cimport AAFObject,AAFBase
from .define cimport DataDef

cdef class EssenceData(AAFObject):
    cdef lib.IAAFEssenceData *ptr

cdef class EssenceFormat(AAFBase):
    cdef lib.IAAFEssenceFormat *ptr

cdef class EssenceMultiAccess(AAFBase):
    cdef lib.IAAFEssenceMultiAccess *essence_ptr

cdef class EssenceAccess(EssenceMultiAccess):
    cdef lib.IAAFEssenceAccess *ptr
    cdef DataDef datadef

cdef class Locator(AAFObject):
    cdef lib.IAAFLocator *loc_ptr

cdef class NetworkLocator(Locator):
    cdef lib.IAAFNetworkLocator *ptr

cdef class EssenceDescriptor(AAFObject):
    cdef lib.IAAFEssenceDescriptor *essence_ptr

cdef class FileDescriptor(EssenceDescriptor):
    cdef lib.IAAFFileDescriptor *file_ptr

cdef class DataEssenceDescriptor(FileDescriptor):
    cdef lib.IAAFDataEssenceDescriptor *ptr

cdef class WAVEDescriptor(FileDescriptor):
    cdef lib.IAAFWAVEDescriptor *ptr

cdef class AIFCDescriptor(FileDescriptor):
    cdef lib.IAAFAIFCDescriptor *ptr

cdef class TIFFDescriptor(FileDescriptor):
    cdef lib.IAAFTIFFDescriptor *ptr

cdef class DigitalImageDescriptor(FileDescriptor):
    cdef lib.IAAFDigitalImageDescriptor *im_ptr

cdef class CDCIDescriptor(DigitalImageDescriptor):
    cdef lib.IAAFCDCIDescriptor *ptr

cdef class RGBADescriptor(DigitalImageDescriptor):
    cdef lib.IAAFRGBADescriptor *ptr

cdef class SoundDescriptor(FileDescriptor):
    cdef lib.IAAFSoundDescriptor *snd_ptr

cdef class PCMDescriptor(SoundDescriptor):
    cdef lib.IAAFPCMDescriptor *ptr

cdef class TapeDescriptor(EssenceDescriptor):
    cdef lib.IAAFTapeDescriptor *ptr

cdef class FilmDescriptor(EssenceDescriptor):
    pass

cdef class PhysicalDescriptor(EssenceDescriptor):
    cdef lib.IAAFPhysicalDescriptor *phys_ptr

cdef class ImportDescriptor(PhysicalDescriptor):
    cdef lib.IAAFImportDescriptor *ptr

cdef class RecordingDescriptor(PhysicalDescriptor):
    pass

cdef class AuxiliaryDescriptor(PhysicalDescriptor):
    pass
