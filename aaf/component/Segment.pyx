cdef class Segment(Component):
    def __cinit__(self):
        self.iid = lib.IID_IAAFSegment
        self.auid = lib.AUID_AAFSegment
        self.seg_ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.seg_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.seg_ptr, lib.IID_IAAFSegment)

        Component.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.seg_ptr:
            self.seg_ptr.Release()