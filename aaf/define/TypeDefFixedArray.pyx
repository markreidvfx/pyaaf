cdef class TypeDefFixedArray(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefFixedArray

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefFixedArray)

        TypeDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def typedef(self):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetType(&typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(typedef)

    def size(self):
        cdef lib.aafUInt32 count
        error_check(self.ptr.GetCount(&count))
        return count

    def create_property_value(self, value):

        cdef lib.aafUInt32 num_elements = self.size()

        if len(value) != num_elements:
            raise ValueError("not enough values, expected %i got %i" % (num_elements, len(value)))

        typedef = self.typedef()

        property_values = []

        for item in value:
            property_values.append(typedef.create_property_value(item))

        cdef PropertyValue working_value
        cdef PropertyValue out_value = PropertyValue.__new__(PropertyValue)

        cdef lib.IAAFPropertyValue ** element_values = <lib.IAAFPropertyValue **> malloc(num_elements * sizeof(lib.IAAFPropertyValue*))
        if not element_values:
            raise MemoryError()

        try:
            for i,working_value in enumerate(property_values):
                element_values[i] = working_value.ptr

            error_check(self.ptr.CreateValueFromValues(element_values, num_elements, &out_value.ptr))
            out_value.query_interface()
            out_value.root = self.root
            return out_value

        finally:
            free(element_values)

    def iter_property_value(self, PropertyValue p_value):
        cdef PropValueIter prop_iter = PropValueIter.__new__(PropValueIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter

    def set_element_value(self, PropertyValue p_value, lib.aafUInt32 index, PropertyValue p_member_value):

        error_check(self.ptr.SetElementValue(p_value.ptr, index, p_member_value.ptr))

    def set_value(self, PropertyValue p_value, value):

        typedef = self.typedef()

        if len(value) > self.size():
            raise ValueError("Value length larger then fixed array, expected < %i got %i", (self.size(), len(value)))

        for i, item in enumerate(value):
            new_value = typedef.create_property_value(item)
            self.set_element_value(p_value, i, new_value)

    def value(self, PropertyValue p_value):
        cdef PropValueResolveIter prop_iter = PropValueResolveIter.__new__(PropValueResolveIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter
