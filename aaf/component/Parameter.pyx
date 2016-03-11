cdef class Parameter(AAFObject):
    """
    A Parameter is an effect control. They are only on OperationGroups.
    """
    def __cinit__(self):
        self.iid = lib.IID_IAAFParameter
        self.auid = lib.AUID_AAFParameter
        self.param_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.param_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.param_ptr, lib.IID_IAAFParameter)

        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.param_ptr:
            self.param_ptr.Release()

    def typedef(self):
        cdef TypeDef type_def = TypeDef.__new__(TypeDef)
        error_check(self.param_ptr.GetTypeDefinition(&type_def.typedef_ptr))
        type_def.query_interface()
        type_def.root = self.root
        return type_def.resolve()

    def parameterdef(self):
        cdef ParameterDef param_def = ParameterDef.__new__(ParameterDef)
        error_check(self.param_ptr.GetParameterDefinition(&param_def.ptr))
        param_def.query_interface()
        param_def.root = self.root
        return param_def

    property name:
        def __get__(self):
            param_def = self.parameterdef()
            return param_def.name

    property value:
        def __get__(self):
            props = list(self.properties())
            if len(props) == 2:
                return props[1].value
            values = []
            for p in props[1:]:
                values.append(p.value)
            return values
