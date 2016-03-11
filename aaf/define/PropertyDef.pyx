cdef class PropertyDef(MetaDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFPropertyDef

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFPropertyDef)

        MetaDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def typedef(self):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetTypeDef(&typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(typedef)

    property optional:
        def __get__(self):
            cdef lib.aafBoolean_t value
            error_check(self.ptr.GetIsOptional(&value))
            if value:
                return True
            return False
