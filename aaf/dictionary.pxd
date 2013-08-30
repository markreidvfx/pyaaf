
cimport lib
from base cimport AAFObject

cdef class Dictionary(AAFObject):
    cdef lib.IAAFDictionary *ptr
    cdef readonly CreateInstance create
    
cdef class CreateInstance(object):
   cdef bytes class_name
   cdef Dictionary dictionary