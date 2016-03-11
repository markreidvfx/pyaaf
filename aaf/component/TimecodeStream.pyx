
cdef class TimecodeStream(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTimecodeStream
        self.auid = lib.AUID_AAFTimecodeStream
        self.timecode_stream_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.timecode_stream_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.timecode_stream_ptr, lib.IID_IAAFTimecodeStream)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.timecode_stream_ptr:
            self.timecode_stream_ptr.Release()
