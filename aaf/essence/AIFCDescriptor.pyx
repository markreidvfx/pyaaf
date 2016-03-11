cdef class AIFCDescriptor(FileDescriptor):
    """
    The AIFCDescriptor class specifies that a File SourceMob is associated with
    audio essence formatted according to the
    Audio Interchange File Format with Compression (AIFC)
    """

    def __cinit__(self):
        self.iid = lib.IID_IAAFAIFCDescriptor
        self.auid = lib.AUID_AAFAIFCDescriptor
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFAIFCDescriptor)

        FileDescriptor.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        error_check(self.ptr.Initialize())

    property summary:
        def __get__(self):
            cdef lib.aafUInt32 bufer_size
            error_check(self.ptr.GetSummaryBufferSize(&bufer_size))
            cdef vector[lib.aafUInt8] buf = vector[lib.aafUInt8]( bufer_size )

            error_check(self.ptr.GetSummary(bufer_size, <lib.aafUInt8 *> &buf[0]))
            cdef lib.aafUInt8 *data = <lib.aafUInt8 *>  &buf[0]
            cdef bytes byte_data = data[:bufer_size]

            return byte_data
            #HRESULT GetSummaryBufferSize(aafUInt32 *pSize)

        def __set__(self, value):

            cdef bytes data
            if isinstance(value, bytes):
                data = value
            else:
                data = value.encode("ascii")

            cdef lib.aafUInt32 bufer_size =  len(data) * sizeof(lib.aafUInt8)

            error_check(self.ptr.SetSummary(bufer_size, <lib.aafUInt8 *> data ))
