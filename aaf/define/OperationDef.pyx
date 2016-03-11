cdef class OperationDef(DefObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFOperationDef
        self.auid = lib.AUID_AAFOperationDef
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFOperationDef)

        DefObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, auid, name, description):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        cdef AUID auid_obj = AUID(auid)

        cdef AAFCharBuffer name_buf = AAFCharBuffer(name)
        cdef AAFCharBuffer description_buf = AAFCharBuffer(name)

        error_check(self.ptr.Initialize(auid_obj.get_auid(), name_buf.get_ptr(), description_buf.get_ptr()))

        # Automaticly set category to effect_category
        effect_category = "0D010102-0101-0100-060E-2B3404010101"
        cdef AUID auid_category = AUID(effect_category)
        error_check(self.ptr.SetCategory(auid_category.get_auid()))

    def add_parameterdef(self, ParameterDef param not None):
        error_check(self.ptr.AddParameterDef(param.ptr))

    property media_kind:
        def __get__(self):
            cdef DataDef data_def = DataDef.__new__(DataDef)
            error_check(self.ptr.GetDataDef(&data_def.ptr))
            data_def.query_interface()
            return data_def.name.replace("DataDef_", "")

        def __set__(self, value):
            cdef Dictionary dictionary = self.dictionary()
            cdef DataDef data_def = dictionary.lookup_datadef(value)
            error_check(self.ptr.SetDataDef(data_def.ptr))

    property categoryID:
        def __get__(self):
            cdef AUID auid_category = AUID()
            error_check(self.ptr.GetCategory(&auid_category.auid))
            return auid_category

        def __set__(self, value):
            cdef AUID auid_category = AUID(value)
            error_check(self.ptr.SetCategory(auid_category.get_auid()))
