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
            cdef lib.aafUInt32 sizeInBytes = 0
            error_check(self.defobject_ptr.GetNameBufLen(&sizeInBytes))
            
            cdef int sizeInChars = (sizeInBytes / sizeof(lib.aafCharacter)) + 1
            cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
            
            error_check(self.defobject_ptr.GetName(&buf[0], sizeInChars*sizeof(lib.aafCharacter) ))
            
            cdef wstring name = wstring(&buf[0])
            return wideToString(name)