            
cdef class WAVEDescriptor(FileDescriptor):
    """
    The WAVEDescriptor class specifies that a File SourceMob is associated with audio essence
    formatted according to the RIFF Waveform Audio File Format (WAVE).
    The WAVEDescriptor class is a sub-class of the FileDescriptor class.
    A WAVEDescriptor object shall be owned by a file SourceMob.
    """

    def __cinit__(self):
        self.iid = lib.IID_IAAFWAVEDescriptor
        self.auid = lib.AUID_AAFWAVEDescriptor
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFWAVEDescriptor)

        FileDescriptor.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        error_check(self.ptr.Initialize())
