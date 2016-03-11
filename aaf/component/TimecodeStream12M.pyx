#Note todo TimecodeStream12M
cdef class TimecodeStream12M(TimecodeStream):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTimecodeStream12M
        self.auid = lib.AUID_AAFTimecodeStream12M
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTimecodeStream12M)

        TimecodeStream.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
