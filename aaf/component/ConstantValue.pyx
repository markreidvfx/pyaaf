cdef class ConstantValue(Parameter):
    def __cinit__(self):
        self.iid = lib.IID_IAAFConstantValue
        self.auid = lib.AUID_AAFConstantValue
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFConstantValue)

        Parameter.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, ParameterDef param_def not None, unsigned char[:] data not None):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        error_check(self.ptr.Initialize(param_def.ptr, len(data), &data[0]))

    property data:
        def __get__(self):
            cdef lib.aafUInt32 size
            cdef lib.aafUInt32 bytes_read
            error_check(self.ptr.GetValueBufLen(&size))
            buf  = bytearray(size)
            cdef unsigned char[:] data = buf
            error_check(self.ptr.GetValue(size, &data[0], &bytes_read))
            assert bytes_read == size
            return buf
        def __set__(self, unsigned char[:] data not None):
            error_check(self.ptr.SetValue(len(data), &data[0]))
