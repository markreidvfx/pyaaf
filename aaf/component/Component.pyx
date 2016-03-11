cdef class Component(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFComponent
        self.auid = lib.AUID_AAFComponent
        self.comp_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.comp_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.comp_ptr, lib.IID_IAAFComponent)

        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.comp_ptr:
            self.comp_ptr.Release()

    def datadef(self):
        cdef DataDef data_def = DataDef.__new__(DataDef)
        error_check(self.comp_ptr.GetDataDef(&data_def.ptr))
        data_def.query_interface()
        data_def.root = self.root
        return data_def.resolve()

    property length:
        def __get__(self):
            if self.has_key("Length"):
                return self['Length'].value
            return None
        def __set__(self, lib.aafLength_t value):
            self['Length'].value = value

    property media_kind:
        def __get__(self):
            return self.datadef().name
        def __set__(self, value):
            cdef DataDef data_def = self.dictionary().lookup_datadef(value)
            self.comp_ptr.SetDataDef(data_def.ptr)
