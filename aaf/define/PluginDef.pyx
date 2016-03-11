cdef class PluginDef(DefObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFPluginDef
        self.auid = lib.AUID_AAFPluginDef
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFPluginDef)

        DefObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
