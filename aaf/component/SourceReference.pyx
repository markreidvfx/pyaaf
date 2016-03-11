cdef class SourceReference(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFSourceReference
        self.auid = lib.AUID_AAFSourceReference
        self.ref_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ref_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ref_ptr, lib.IID_IAAFSourceReference)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.ref_ptr:
            self.ref_ptr.Release()
