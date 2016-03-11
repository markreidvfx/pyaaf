cdef class PhysicalDescriptor(EssenceDescriptor):
    def __cinit__(self):
        self.iid = lib.IID_IAAFPhysicalDescriptor
        self.auid = lib.AUID_AAFPhysicalDescriptor
        self.phys_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.phys_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.phys_ptr, lib.IID_IAAFPhysicalDescriptor)

        EssenceDescriptor.query_interface(self, obj)

    def __dealloc__(self):
        if self.phys_ptr:
            self.phys_ptr.Release()
