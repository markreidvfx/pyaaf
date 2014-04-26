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
            cdef lib.aafUInt32 sizeInBytes = 0
            error_check(self.meta_ptr.GetNameBufLen(&sizeInBytes))
            
            cdef int sizeInChars = (sizeInBytes / sizeof(lib.aafCharacter)) + 1
            cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
            
            error_check(self.meta_ptr.GetName(&buf[0], sizeInChars*sizeof(lib.aafCharacter) ))
            
            cdef wstring name = wstring(&buf[0])
            return wideToString(name)
        
    property description:
        def __get__(self):
            cdef lib.aafUInt32 sizeInBytes = 0
            error_check(self.meta_ptr.GetDescriptionBufLen(&sizeInBytes))
            
            cdef int sizeInChars = (sizeInBytes / sizeof(lib.aafCharacter)) + 1
            cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
            
            error_check(self.meta_ptr.GetDescription(&buf[0], sizeInChars*sizeof(lib.aafCharacter) ))
            
            cdef wstring name = wstring(&buf[0])
            return wideToString(name)
    
    property auid:
        def __get__(self):
            cdef AUID auid = AUID()
            error_check(self.meta_ptr.GetAUID(&auid.auid))
            return auid
        