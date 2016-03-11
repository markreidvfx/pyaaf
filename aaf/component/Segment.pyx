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


    def offset_to_tc(self, lib.aafPosition_t offset):
        """
        Converts the given segment offset to a timecode value
        """
        cdef util.Timecode tc = util.Timecode.__new__(util.Timecode)
        error_check(self.seg_ptr.SegmentOffsetToTC(&offset, &tc.timecode))
        return tc

    def tc_to_offset(self, util.Timecode timecode, edit_rate):
        """
        Converts the given timecode and edit rate to a segment offset value.
        """
        cdef lib.aafFrameOffset_t result
        cdef lib.aafRational_t rate
        fraction_to_aafRational(edit_rate, rate)
        error_check(self.seg_ptr.SegmentTCToOffset(&timecode.timecode, &rate, &result))
        return result
