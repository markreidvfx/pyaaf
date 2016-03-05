cdef class TypeDefSet(TypeDef):
    def __cinit__(self):
        self.ptr == NULL
        self.iid = lib.IID_IAAFTypeDefSet

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefSet)

        TypeDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def size(self, PropertyValue p_value):
        cdef lib.aafUInt32 count
        error_check(self.ptr.GetCount(p_value.ptr, &count))
        return count

    def element_typedef(self):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetElementType(&typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(typedef)

    def iter_property_value(self, PropertyValue p_value):
        cdef PropValueIter prop_iter = PropValueIter.__new__(PropValueIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter

    def value(self, PropertyValue p_value):
        cdef PropValueResolveIter prop_iter = PropValueResolveIter.__new__(PropValueResolveIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter
