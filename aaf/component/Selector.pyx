cdef class Selector(Segment):
    """
    Provides the value of a single Segment while preserving references to unused alternatives.
    """
    def __cinit__(self):
        self.iid = lib.IID_IAAFSelector
        self.auid = lib.AUID_AAFSelector
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFSelector)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def alternate_segments(self):
        cdef SegmentIter value = SegmentIter.__new__(SegmentIter)
        error_check(self.ptr.EnumAlternateSegments(&value.ptr))
        value.root = self.root
        return value
            
    property segment:
        def __get__(self):
            cdef Segment seg = Segment.__new__(Segment)
            error_check(self.ptr.GetSelectedSegment(&seg.seg_ptr))
            seg.query_interface()
            seg.root = self.root
            return seg.resolve()