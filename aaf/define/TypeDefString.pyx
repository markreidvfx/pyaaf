cdef class TypeDefString(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefString
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefString)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def typedef(self):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetType(&typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(TypeDef(typedef))
            
    def set_value(self, PropertyValue p_value, bytes value):

        cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)
        
        buf.write_str(value)
        buf.null_terminate()
        
        #print len(value), buf.size(), buf.size_in_bytes()

        #cdef lib.aafUInt32 size_in_bytes =  buf.buf.size() * sizeof(lib.aafCharacter)
        error_check(self.ptr.SetCString(p_value.ptr,
                                        <lib.aafMemPtr_t> buf.to_aafchar(),
                                        buf.size_in_bytes))
        
        #print self.value(p_value)
    
    def value(self, PropertyValue p_value ):
        
        cdef lib.aafUInt32 sizeInChars
        cdef int sizeInBytes
        
        error_check(self.ptr.GetCount(p_value.ptr, &sizeInChars))
        sizeInBytes = sizeof(lib.aafCharacter)*sizeInChars
        
        if not sizeInBytes:
            return None
        
        cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter]( sizeInChars )
        
        
        error_check(self.ptr.GetElements(p_value.ptr,
                                         <lib.aafMemPtr_t> &buf[0],
                                         sizeInBytes))
        
        cdef wstring value = wstring(&buf[0])
        return wideToString(value)