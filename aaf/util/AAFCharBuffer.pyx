import sys

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
        self.python_maxunicode = sys.maxunicode
        self.aaf_maxunicode = 0x10FFFF
    
    cdef from_wstring(self, wstring value):
        
        cdef const wchar_t *ptr = value.c_str()
        cdef wchar_t item
        for i in xrange(value.size()):
            item = ptr[i]
            self.buf.push_back(item)
        # Added null terminator
        self.null_terminate()
        
    cpdef null_terminate(self):
        self.buf.push_back('\0')
        
    cdef write_aafchar(self, lib.aafCharacter value):
        self.buf.push_back(value)
        
    cpdef write_unicode(self, unicode value):
        cdef Py_UNICODE c
        
        for c in value:
            if <unsigned long> c > self.aaf_maxunicode:
                raise ValueError()
            
            self.buf.push_back(c)

    cpdef write_bytes(self, bytes value):
        cdef char c
        for c in value:
            self.buf.push_back(c)
        
    cpdef unicode read_unicode(self):
        cdef unicode unicode_str = u""
        cdef Py_UNICODE c

        cdef lib.aafCharacter * aaf_ptr = self.to_aafchar()
        
        for i in xrange(self.size()):
            c = aaf_ptr[i]
            unicode_str += c
            
        return unicode_str
        
    cpdef bytes read_bytes(self):
        cdef bytes bytes_str = b""
        cdef char c
        
        cdef lib.aafCharacter * aaf_ptr = self.to_aafchar()
        
        for i in xrange(self.size()):
            c = aaf_ptr[i]
            bytes_str += <bytes> c
            
        return bytes_str
    
    cpdef write_str(self, object string):
        if isinstance(string, unicode):
            self.write_unicode(string)
        self.write_bytes(string)
        
    cpdef from_string(self, bytes value):
        self.from_wstring(toWideString(value))
        
    cpdef bytes to_string(self):
        return wideToString(self.to_wstring())
    
    cdef wstring to_wstring(self):
        cdef wstring value = wstring(&self.buf[0], self.buf.size())
        return value
    
    cdef lib.aafCharacter* to_aafchar(self):
        return <lib.aafCharacter *> &self.buf[0]

    cdef wchar_t* to_wchar(self):
        return <wchar_t *> &self.buf[0]
    
    cpdef set_size(self, size_t size):
        self.buf.resize(size)
    
    cpdef size_t size(self):
        return self.buf.size()
    
    cpdef size_t size_in_bytes(self):
        return self.buf.size() * sizeof(lib.aafCharacter)
    
    def aafchar_size(self):
        return sizeof(lib.aafCharacter)
    
    def unicode_size(self):
        return sizeof(Py_UNICODE)
    
    cpdef bytes raw_data(self):
        cdef char * data = <char *> &self.buf[0]
        return data[:self.size_in_bytes()]
    
    def w_dump(self):
        print_wchar(self.to_aafchar())
    
    def __str__(self):
        return self.to_string()