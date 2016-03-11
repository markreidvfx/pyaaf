# Note Opaque inherits TypeDefIndirect
cdef class TypeDefOpaque(TypeDefIndirect):
    def __cinit__(self):
        self.opaque_ptr = NULL
        self.iid = lib.IID_IAAFTypeDefOpaque

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.opaque_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.opaque_ptr, lib.IID_IAAFTypeDefOpaque)

        TypeDefIndirect.query_interface(self, obj)

    def __dealloc__(self):
        if self.opaque_ptr:
            self.opaque_ptr.Release()
