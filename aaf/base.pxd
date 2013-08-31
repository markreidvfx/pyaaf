cimport lib

cdef class AUID(object):
    cdef lib.aafUID_t auid
    cdef lib.GUID iid
    cdef lib.aafUID_t get_auid(self)
    cdef lib.GUID get_iid(self)
    cdef void from_auid(self, lib.aafUID_t auid)
    cdef void from_iid(self, lib.GUID iid)
    
cdef class AAFBase(object):
    cdef lib.IUnknown *base_ptr
    cdef lib.IUnknown **get(self)
    cdef resolve(self)
    cdef lib.GUID iid

cdef class AAFObject(AAFBase):
    cdef lib.IAAFObject *obj_ptr
    cdef lib.aafUID_t auid