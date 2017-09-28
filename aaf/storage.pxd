cimport lib
from base cimport AAFObject,AAFBase

cdef class File(AAFBase):
    cdef object __weakref__
    cdef lib.IAAFFile *ptr
    cdef object mode
    cdef lib.aafProductIdentification_t productInfo
    cdef object setup_new_file(self, path, mode=*, identification=*)

cdef class Header(AAFObject):
    cdef lib.IAAFHeader *ptr
    cdef lib.IAAFHeader2 *ptr2

cdef class ContentStorage(AAFObject):
    cdef lib.IAAFContentStorage *ptr

cdef class Identification(AAFObject):
    cdef lib.IAAFIdentification *ptr
