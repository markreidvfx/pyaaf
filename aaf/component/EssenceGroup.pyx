cdef class EssenceGroup(Segment):
    """
    Describes multiple digital representations of the same original content source.
    """
    def __cinit__(self):
        self.iid = lib.IID_IAAFEssenceGroup
        self.auid = lib.AUID_AAFEssenceGroup
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFEssenceGroup)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def choice_at(self, lib.aafUInt32 index):
        cdef Segment seg = Segment.__new__(Segment)
        error_check(self.ptr.GetChoiceAt(index, &seg.seg_ptr))

        seg.query_interface()
        seg.root = self.root
        return seg.resolve()


    def choices(self):
        for i in xrange(self.count):
            yield self.choice_at(i)

    property count:
        def __get__(self):
            cdef lib.aafUInt32 value
            error_check(self.ptr.CountChoices(&value))
            return value

    property still_frame:
        def __get__(self):
            cdef SourceClip clip = SourceClip.__new__(SourceClip)

            cdef lib.HRESULT result
            result = self.ptr.GetStillFrame(&clip.ptr)

            if result == lib.AAFRESULT_PROP_NOT_PRESENT:
                return None
            else:
                error_check(result)

            clip.query_interface()
            clip.root = self.root
            return clip

        def __set__(self, SourceClip value not None):
            error_check(self.ptr.SetStillFrame(value.ptr))
