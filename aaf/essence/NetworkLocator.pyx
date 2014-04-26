cdef class NetworkLocator(Locator):
    def __cinit__(self):
        self.iid = lib.IID_IAAFNetworkLocator
        self.auid = lib.AUID_AAFNetworkLocator
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.loc_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFNetworkLocator)

        Locator.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.loc_ptr:
            self.loc_ptr.Release()
            
    def initialize(self):
        error_check(self.ptr.Initialize())