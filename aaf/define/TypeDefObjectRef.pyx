cdef class TypeDefObjectRef(TypeDef):
    def __cinit__(self):
        self.ref_ptr = NULL
        self.iid = lib.IID_IAAFTypeDefObjectRef

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ref_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ref_ptr, lib.IID_IAAFTypeDefObjectRef)

        TypeDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ref_ptr:
            self.ref_ptr.Release()

    def create_property_value(self, AAFBase value not None):
        cdef PropertyValue out_value = PropertyValue.__new__(PropertyValue)
        error_check(self.ref_ptr.CreateValue(value.base_ptr, &out_value.ptr))
        out_value.query_interface()
        out_value.root = self.root
        return out_value

    def object_type(self):
        cdef ClassDef class_def = ClassDef.__new__(ClassDef)
        error_check(self.ref_ptr.GetObjectType(&class_def.ptr))
        class_def.query_interface()
        class_def.root = self.root
        return class_def

    def set_value(self, PropertyValue p_value, value):
        new_value = self.create_property_value(value)
        return new_value

    def value(self, PropertyValue p_value ):
        cdef AAFBase obj = AAFBase.__new__(AAFBase)
        error_check(self.ref_ptr.GetObject(p_value.ptr, lib.IID_IUnknown, &obj.base_ptr))
        obj.root = self.root
        return obj.resolve()
