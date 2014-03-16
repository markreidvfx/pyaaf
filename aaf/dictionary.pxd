
cimport lib
from base cimport AAFObject

cdef class Dictionary(AAFObject):
    cdef lib.IAAFDictionary *ptr
    cdef lib.IAAFDictionary2 *ptr2
    cdef readonly CreateInstance create
    cdef create_instance(self, AAFObject)
    
cdef class PluginManager(object):
    cdef lib.IAAFPluginManager *ptr
    
cdef class CreateInstance(object):
   cdef bytes class_name
   cdef Dictionary dictionary