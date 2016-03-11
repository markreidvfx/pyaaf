cdef class TIFFDescriptor(FileDescriptor):
    """
    The TIFFDescriptor class specifies that a File SourceMob
    is associated with video essence formatted according to
    the TIFF specification.
    """

    def __cinit__(self):
        self.iid = lib.IID_IAAFTIFFDescriptor
        self.auid = lib.AUID_AAFTIFFDescriptor
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTIFFDescriptor)

        FileDescriptor.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
