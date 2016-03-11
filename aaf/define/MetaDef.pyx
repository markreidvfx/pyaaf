cdef class MetaDef(AAFBase):
    def __cinit__(self):
        self.meta_ptr = NULL
        self.iid = lib.IID_IAAFMetaDefinition

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.meta_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.meta_ptr, lib.IID_IAAFMetaDefinition)

        AAFBase.query_interface(self, obj)

    def __dealloc__(self):
        if self.meta_ptr:
            self.meta_ptr.Release()

    property name:
        def __get__(self):

            cdef lib.aafUInt32 size_in_bytes = 0
            error_check(self.meta_ptr.GetNameBufLen(&size_in_bytes))

            cdef AAFCharBuffer buf = AAFCharBuffer()
            buf.size_in_bytes = size_in_bytes

            error_check(self.meta_ptr.GetName(buf.get_ptr(),  buf.size_in_bytes))

            # strip off Null Terminator
            return buf.read_str()


    property description:
        def __get__(self):
            cdef lib.aafUInt32 size_in_bytes = 0
            error_check(self.meta_ptr.GetDescriptionBufLen(&size_in_bytes))

            cdef AAFCharBuffer buf = AAFCharBuffer()
            buf.size_in_bytes = size_in_bytes

            error_check(self.meta_ptr.GetDescription(buf.get_ptr(),  buf.size_in_bytes))

            # strip off Null Terminator
            return buf.read_str()

    property auid:
        def __get__(self):
            cdef AUID auid = AUID()
            error_check(self.meta_ptr.GetAUID(&auid.auid))
            return auid
