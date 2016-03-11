cdef class EssenceMultiAccess(AAFBase):
    def __cinit__(self):
        self.iid = lib.IID_IAAFEssenceMultiAccess
        self.essence_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.essence_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.essence_ptr, lib.IID_IAAFEssenceMultiAccess)

        AAFBase.query_interface(self, obj)

    def __dealloc__(self):
        if self.essence_ptr:
            self.essence_ptr.Release()
