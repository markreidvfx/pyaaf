cdef class DescriptiveMarker(CommentMarker):
    def __cinit__(self):
        self.iid = lib.IID_IAAFDescriptiveMarker
        self.auid = lib.AUID_AAFDescriptiveMarker
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFDescriptiveMarker)

        CommentMarker.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        error_check(self.ptr.Initialize())

    def set_described_slot_ids(self, values):
        cdef vector[lib.aafUInt32] buf

        for item in values:
            buf.push_back(item)

        error_check(self.ptr.SetDescribedSlotIDs(buf.size(), &buf[0]))
