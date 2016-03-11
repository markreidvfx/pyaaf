cdef class ControlPoint(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFControlPoint
        self.auid = lib.AUID_AAFControlPoint
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFControlPoint)

        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, VaryingValue varying_value not None, time, value):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)


        cdef lib.aafRational_t time_t
        fraction_to_aafRational(time, time_t)

        cdef lib.aafRational_t value_t
        fraction_to_aafRational(value, value_t)

        # typedef varying_value.typedef()

        error_check(self.ptr.Initialize(varying_value.ptr, time_t, sizeof(lib.aafRational_t), <lib.aafDataBuffer_t> &value_t))


    def typedef(self):
        cdef TypeDef type_def = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetTypeDefinition(&type_def.typedef_ptr))
        type_def.query_interface()
        type_def.root = self.root
        return type_def.resolve()

    def point_properties(self):
        prop = self.get('ControlPointPointProperties', None)
        if prop:
            return prop.value
        return []

    property time:
        def __get__(self):
            return self['Time'].value
        def __set__(self, value):
            cdef lib.aafRational_t value_t
            fraction_to_aafRational(value, value_t)
            error_check(self.ptr.SetTime(value_t))

    property value:
        def __get__(self):
            return self['Value'].value
        def __set__(self, value):
            self['Value'].value = value

    property edit_hint:
        def __get__(self):
            return self['EditHint'].value
