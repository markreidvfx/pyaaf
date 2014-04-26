cdef class TapeDescriptor(EssenceDescriptor):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTapeDescriptor
        self.auid = lib.AUID_AAFTapeDescriptor
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTapeDescriptor)

        EssenceDescriptor.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def initialize(self):
        error_check(self.ptr.Initialize())