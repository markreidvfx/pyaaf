cdef class CommentMarker(Event):
    def __cinit__(self):
        self.iid = lib.IID_IAAFCommentMarker
        self.auid = lib.AUID_AAFCommentMarker
        self.comment_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.comment_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.comment_ptr, lib.IID_IAAFCommentMarker)

        Event.query_interface(self, obj)

    def __dealloc__(self):
        if self.comment_ptr:
            self.comment_ptr.Release()
