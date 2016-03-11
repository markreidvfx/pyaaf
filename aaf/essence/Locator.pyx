cdef class Locator(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFLocator
        self.auid = lib.AUID_AAFLocator
        self.loc_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.loc_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.loc_ptr, lib.IID_IAAFLocator)

        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.loc_ptr:
            self.loc_ptr.Release()

    property path:
        """
        Absolute Uniform Resource Locator (URL) complying with RFC 1738 or
        relative Uniform Resource Identifier (URI) complying with RFC 2396
        for file containing the essence. If it is a relative URI,
        the base URI is determined from the URI of the AAF file itself.
        """
        def __get__(self):

            cdef lib.aafUInt32 size_in_bytes = 0
            error_check(self.loc_ptr.GetPathBufLen(&size_in_bytes))

            cdef AAFCharBuffer buf = AAFCharBuffer()
            buf.size_in_bytes = size_in_bytes

            error_check(self.loc_ptr.GetPath(buf.get_ptr(),  buf.size_in_bytes))

            # strip off Null Terminator
            return buf.read_str()

        def __set__(self, value):
            cdef AAFCharBuffer buf = AAFCharBuffer(value)

            error_check(self.loc_ptr.SetPath(buf.get_ptr()))
