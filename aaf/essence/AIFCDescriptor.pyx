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

    def initialize(self):
        error_check(self.ptr.Initialize())
        
    property summary:
        def __get__(self):
            cdef lib.aafUInt32 bufer_size
            error_check(self.ptr.GetSummaryBufferSize(&bufer_size))
            cdef vector[lib.aafUInt8] buf = vector[lib.aafUInt8]( bufer_size )
            
            error_check(self.ptr.GetSummary(bufer_size, <lib.aafUInt8 *> &buf[0]))
            cdef lib.aafUInt8 *data = <lib.aafUInt8 *>  &buf[0]
            return data[:bufer_size]
            #HRESULT GetSummaryBufferSize(aafUInt32 *pSize)

        def __set__(self, bytes value):
            cdef lib.aafUInt32 bufer_size =  len(value) * sizeof(lib.aafUInt8)
            error_check(self.ptr.SetSummary(bufer_size, <lib.aafUInt8 *> value ))