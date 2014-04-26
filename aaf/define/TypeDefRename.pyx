cdef class TypeDefRename(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefRename
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefRename)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def resolve_rename(self, PropertyValue p_value):
        cdef PropertyValue out_value = PropertyValue.__new__(PropertyValue)
        error_check(self.ptr.GetBaseValue(p_value.ptr, &out_value.ptr))
        out_value.query_interface()
        out_value.root = self.root
        return out_value
            
    def set_value(self, PropertyValue p_value, value):        
        self.resolve_rename(p_value).value = value

            
    def value(self, PropertyValue p_value):
        cdef PropertyValue out_value = self.resolve_rename(p_value)
        
        value =  out_value.value
        if value is None:
            raise NotImplementedError("typedef rename of value type %s not implemented" % str(out_value.typedef()))
        return value