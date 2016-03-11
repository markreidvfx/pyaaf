cdef class TypeDefVariableArray(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefVariableArray

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefVariableArray)

        TypeDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, TypeDef typedef not None, AUID auid not None, name not None):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_meta_instance(self, lib.AUID_AAFTypeDefVariableArray)

        cdef AAFCharBuffer buf = AAFCharBuffer(name)

        error_check(self.ptr.Initialize(auid.get_auid(), typedef.typedef_ptr, buf.get_ptr()))

        dictionary.register_def(self)

    def create_empty_value(self):
        cdef PropertyValue empty_value = PropertyValue.__new__(PropertyValue)
        error_check(self.ptr.CreateEmptyValue(&empty_value.ptr))
        empty_value.query_interface()
        empty_value.root = self.root
        return empty_value

    def append_element(self, PropertyValue p_value not None, PropertyValue p_value_element not None):

        error_check(self.ptr.AppendElement(p_value.ptr, p_value_element.ptr ))

    def type(self):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetType(&typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(typedef)

    def size(self,PropertyValue p_value):
        cdef lib.aafUInt32 count
        error_check(self.ptr.GetCount(p_value.ptr, &count))
        return count

    def property_values(self, PropertyValue p_value):
        cdef PropValueIter prop_iter = PropValueIter.__new__(PropValueIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter

    def set_value(self, PropertyValue p_value, value):

        out_value = self.create_empty_value()
        out_typedef = out_value.typedef()

        typedef = self.type()

        for item in value:
            item_value = typedef.create_property_value(item)
            out_typedef.append_element(out_value, item_value)

        return out_value

    def value(self, PropertyValue p_value):
        cdef PropValueResolveIter prop_iter = PropValueResolveIter.__new__(PropValueResolveIter)
        error_check(self.ptr.GetElements(p_value.ptr, &prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter
