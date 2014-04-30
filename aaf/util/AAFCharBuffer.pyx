
cdef class AAFCharBuffer(object):

    """
    A helper Object for allocating aafCharacter 
    Note: all strings/characters in AAF files are 2-byte unicode, (UTF-16)
    However he AAF SDK uses wchar_t whichs size of which varies across platforms(sometimes 2 or for 4).
    The SDK transforms the in memory wchar_t, whatever size it is, to 2-byte automatically when writing file data.
    However Python can also have different bytes sizes of unicode, 
    example:
        on a macosx 10.9.2, python 2.7
        sizeof(wchar_t) == 4
        sizeof(Py_UNICODE) == 2
    """

    def __cinit__(self):
        self.buf = vector[lib.aafCharacter]()
        
    def __init__(self, value=None):
        if value is not None:
            self.write_str(value)
            self.null_terminate()
        
    cpdef null_terminate(self):
        self.buf.push_back('\0')
        
    cpdef write_str(self, object string):
        if isinstance(string, unicode):
            self.write_unicode(string)
        elif isinstance(string, bytes):
            self.write_bytes(string)
        else:
            self.write_unicode(unicode(string))
        
    cdef write_aafchar(self, lib.aafCharacter value):
        self.buf.push_back(value)
        
    cpdef write_unicode(self, unicode value):
        cdef Py_UCS4 c
        
        for c in value:            
            self.buf.push_back(c)

    cpdef write_bytes(self, bytes value):
        cdef char c
        for c in value:
            self.buf.push_back(c)
        
    cpdef unicode read_unicode(self):
        cdef unicode unicode_str = u""
        cdef Py_UCS4 c

        cdef lib.aafCharacter * aaf_ptr = self.get_ptr()
        
        for i in xrange(self.size):
            c = aaf_ptr[i]
            unicode_str += c
            
        return unicode_str
        
    cpdef bytes read_bytes(self):
        cdef bytes bytes_str = b""
        cdef char c
        
        cdef lib.aafCharacter * aaf_ptr = self.get_ptr()
        
        for i in xrange(self.size):
            c = aaf_ptr[i]
            bytes_str += <bytes> c
            
        return bytes_str
    
    cpdef object read_str(self):
        return self.read_unicode()
    
    cpdef bytes read_raw(self):
        cdef char * data = <char *> &self.buf[0]
        return data[:self.size_in_bytes]
    
    cdef lib.aafCharacter* get_ptr(self):
        return <lib.aafCharacter *> &self.buf[0]
    
    property size_in_bytes:
        def __get__(self):
            return self.buf.size() * sizeof(lib.aafCharacter)
        
        def __set__(self, size_t size):
            self.buf.resize(size / self.aafchar_size)
    
    property size:
        def __get__(self):
            return self.buf.size()
        
        def __set__(self, size_t size):
            self.buf.resize(size)
    
    property aafchar_size:
    
        def __get__(self):
            return sizeof(lib.aafCharacter)
    
    property unicode_size:
    
        def __get__(self):
            return sizeof(Py_UNICODE)
    
    def dump(self):
        print_wchar(self.get_ptr())
