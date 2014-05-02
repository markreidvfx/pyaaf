
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
        
        if sizeof(lib.aafCharacter) == 4:
            self.encoding = "utf_32_le"
        elif sizeof(lib.aafCharacter) == 2:
            self.encoding = "utf_16_le"
        else:
            raise RuntimeError("Unknown aafCharacter encoding")
        
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
    
        cdef bytes data = value.encode(self.encoding)
        
        self.size_in_bytes = len(data)
        
        cdef char * c_data = data 
        memcpy(self.get_ptr(), c_data, len(data))

    cpdef write_bytes(self, bytes value):
        self.write_unicode(value.decode("ascii"))
        
    cpdef unicode read_unicode(self):
    
        cdef bytes data = self.read_raw()
        return data.decode(self.encoding)

    cpdef bytes read_bytes(self): 
        return self.read_unicode().encode("ascii")
    
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
    
    def dump(self):
        print_wchar(self.get_ptr())
