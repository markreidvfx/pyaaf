cdef class DefObject(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFDefObject
        self.auid = lib.AUID_AAFDefObject
        self.defobject_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.defobject_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.defobject_ptr, lib.IID_IAAFDefObject)

        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.defobject_ptr:
            self.defobject_ptr.Release()

    property name:
        def __get__(self):

            cdef lib.aafUInt32 size_in_bytes = 0
            error_check(self.defobject_ptr.GetNameBufLen(&size_in_bytes))

            cdef AAFCharBuffer buf = AAFCharBuffer()
            buf.size_in_bytes = size_in_bytes

            error_check(self.defobject_ptr.GetName(buf.get_ptr(),  buf.size_in_bytes))

            # strip off Null Terminator
            return buf.read_str()
