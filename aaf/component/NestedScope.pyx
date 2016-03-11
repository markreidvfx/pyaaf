cdef class NestedScope(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFNestedScope
        self.auid = lib.AUID_AAFNestedScope
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFNestedScope)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def segments(self):
        cdef SegmentIter seg_iter = SegmentIter.__new__(SegmentIter)
        error_check(self.ptr.GetSegments(&seg_iter.ptr))
        seg_iter.root = self.root
        return seg_iter
