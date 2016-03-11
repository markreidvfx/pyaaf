cdef class Filler(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFFiller
        self.auid = lib.AUID_AAFFiller
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFFiller)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, media_kind not None, lib.aafLength_t length):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)
        error_check(self.ptr.Initialize(data_def.ptr, length))
