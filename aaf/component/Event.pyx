cdef class Event(Segment):
    def __cinit__(self, AAFBase obj = None):
        self.iid = lib.IID_IAAFEvent
        self.auid = lib.AUID_AAFEvent
        self.event_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.event_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.event_ptr, lib.IID_IAAFEvent)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.event_ptr:
            self.event_ptr.Release()
