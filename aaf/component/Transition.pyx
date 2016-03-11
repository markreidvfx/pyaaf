cdef class Transition(Component):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTransition
        self.auid = lib.AUID_AAFTransition
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTransition)

        Component.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    property cutpoint:
        def __get__(self):
            cdef lib.aafPosition_t value
            error_check(self.ptr.GetCutPoint(&value))
            return value

    property operation_group:
        def __get__(self):
            return self['OperationGroup'].value
