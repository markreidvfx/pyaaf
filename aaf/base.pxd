cimport lib

cdef class AAFBase(object):
    cdef lib.GUID iid
    cdef readonly object root
    cdef lib.IUnknown *base_ptr
    cdef lib.IUnknown **get_ptr(self)
    cdef resolve(self)
    cdef query_interface(self, AAFBase obj=*)

cdef class AAFObject(AAFBase):
    cdef lib.aafUID_t auid
    cdef lib.IAAFObject *obj_ptr
