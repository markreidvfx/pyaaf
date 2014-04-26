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
            
            cdef lib.aafUInt32  size_in_bytes
            error_check(self.loc_ptr.GetPathBufLen(&size_in_bytes))
            cdef int size_in_chars = (size_in_bytes / sizeof(lib.aafCharacter)) + 1
            cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter]( size_in_chars )
            
            error_check(self.loc_ptr.GetPath(&buf[0], size_in_bytes))            
            cdef wstring w_name = wstring(&buf[0])
            return wideToString(w_name)

        def __set__(self, bytes value):
            
            cdef wstring w_value = toWideString(value)
            error_check(self.loc_ptr.SetPath(w_value.c_str()))