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

    def __init__(self, root, media_kind not None, lib.aafLength_t length):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        self.media_kind = media_kind
        self.length = length

    def append(self, Segment seg not None):
        error_check(self.ptr.AppendSegment(seg.seg_ptr))

    def prepend(self, Segment seg not None):
        error_check(self.ptr.PrependSegment(seg.seg_ptr))

    def insert(self, lib.aafUInt32 index, Segment seg not None):
        error_check(self.ptr.InsertSegmentAt(index, seg.seg_ptr))

    def remove(self, lib.aafUInt32 index):
        error_check(self.ptr.RemoveSegmentAt(index))

    property count:
        def __get__(self):
            cdef lib.aafUInt32 count
            error_check(self.ptr.CountSegments(&count))
            return count
