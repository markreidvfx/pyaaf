cdef class TypeDef(MetaDef):
    def __cinit__(self):
        self.typedef_ptr = NULL
        self.iid = lib.IID_IAAFTypeDef

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.typedef_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.typedef_ptr, lib.IID_IAAFTypeDef)

        MetaDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.typedef_ptr:
            self.typedef_ptr.Release()

    def value(self, PropertyValue p_value ):
        raise NotImplementedError("value method not implemented for type %s" %(str(self)))

    def set_value(self, PropertyValue p_value, value):
        raise NotImplementedError("set value method not implemented for type %s" %(str(self)))

    property category:
        def __get__(self):
            cdef lib.eAAFTypeCategory_t cat
            error_check(self.typedef_ptr.GetTypeCategory(&cat))
            return cat
