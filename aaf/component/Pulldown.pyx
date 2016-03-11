cdef class Pulldown(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFPulldown
        self.auid = lib.AUID_AAFPulldown
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFPulldown)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, media_kind not None):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        self.media_kind = media_kind

    property kind:
        def __get__(self):
            return self['PulldownKind'].value
        def __set__(self, value):
            self['PulldownKind'].value = value

    property direction:
        def __get__(self):
            return self['PulldownDirection'].value
        def __set__(self, value):
            self['PulldownDirection'].value = value

    property phase:
        def __get__(self):
            return self['PhaseFrame'].value
        def __set__(self, lib.aafPhaseFrame_t value):
            self['PhaseFrame'].value = value


    property segment:
        def __get__(self):
            cdef Segment seg = Segment.__new__(Segment)
            error_check(self.ptr.GetInputSegment(&seg.seg_ptr))
            seg.query_interface()
            seg.root = self.root
            return seg.resolve()
        def __set__(self, Segment value):
            error_check(self.ptr.SetInputSegment(value.seg_ptr))
