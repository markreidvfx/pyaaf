cdef class TypeDefIndirect(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefIndirect

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefIndirect)

        TypeDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def indirect_value(self, PropertyValue p_value):
        cdef PropertyValue out_value = PropertyValue.__new__(PropertyValue)
        error_check(self.ptr.GetActualValue(p_value.ptr, &out_value.ptr))
        out_value.query_interface()
        out_value.root = self.root
        return out_value

    def create_value(self, PropertyValue p_value):
        cdef PropertyValue out_value = PropertyValue.__new__(PropertyValue)
        error_check(self.ptr.CreateValueFromActualValue(p_value.ptr, &out_value.ptr))
        out_value.query_interface()
        out_value.root = self.root
        return out_value

    def actual_typedef(self, PropertyValue p_value):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetActualType(p_value.ptr, &typedef.typedef_ptr))
        typedef.query_interface()
        typedef= self.root
        return resolve_typedef(typedef)


    def set_value(self, PropertyValue p_value, object value):
        cdef PropertyValue indirect_value = self.indirect_value(p_value)
        indirect_value =  indirect_value.set_value(value)
        return self.create_value(indirect_value)

    def value(self, PropertyValue p_value):
        cdef PropertyValue out_value = self.indirect_value(p_value)
        value =  out_value.value
        if value is None:
            raise NotImplementedError("typedef rename of value type %s not implemented" % str(out_value.typedef()))
        return value
