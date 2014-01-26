cimport lib
    
cdef class AAFBase(object):
    cdef lib.IUnknown *base_ptr
    cdef lib.IUnknown **get_ptr(self)
    cdef resolve(self)
    cdef lib.GUID iid

cdef class AAFObject(AAFBase):
    cdef lib.IAAFObject *obj_ptr
    cdef lib.aafUID_t auid