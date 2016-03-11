
cimport lib
from base cimport AAFObject
from define cimport TypeDef

cdef class Dictionary(AAFObject):
    cdef lib.IAAFDictionary *ptr
    cdef lib.IAAFDictionary2 *ptr2
    cdef readonly CreateInstance create
    cdef create_instance(self, AAFObject)
    cdef create_meta_instance(self, TypeDef, lib.aafUID_t)

cdef class PluginManager(object):
    cdef lib.IAAFPluginManager *ptr

cdef class CreateInstance(object):
   cdef object class_name
   cdef Dictionary dictionary
