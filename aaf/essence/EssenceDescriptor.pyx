cdef class EssenceDescriptor(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFEssenceDescriptor
        self.auid = lib.AUID_AAFEssenceDescriptor
        self.essence_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.essence_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.essence_ptr, lib.IID_IAAFEssenceDescriptor)

        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.essence_ptr:
            self.essence_ptr.Release()

    def append_locator(self, Locator loc):
        error_check(self.essence_ptr.AppendLocator(loc.loc_ptr))

    def locators(self):
        cdef LocatorIter loc_iter = LocatorIter.__new__(LocatorIter)
        error_check(self.essence_ptr.GetLocators(&loc_iter.ptr))
        loc_iter.root = self.root
        return loc_iter
