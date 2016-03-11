cdef class TypeDefEnum(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefEnum

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefEnum)

        TypeDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def size(self):
        cdef lib.aafUInt32 count
        error_check(self.ptr.CountElements(&count))
        return count

    def create_property_value(self, value):

        cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)
        buf.write_str(value)

        cdef PropertyValue out_value = PropertyValue.__new__(PropertyValue)

        error_check(self.ptr.CreateValueFromName(buf.get_ptr(), &out_value.ptr))

        out_value.query_interface()
        out_value.root = self.root
        return out_value

    def element_typedef(self):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetElementType(&typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(typedef)

    def element_name(self, lib.aafUInt32 index):
        cdef lib.aafUInt32 size_in_bytes
        error_check(self.ptr.GetElementNameBufLen(index, &size_in_bytes))

        cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)

        buf.size_in_bytes = size_in_bytes

        error_check(self.ptr.GetElementName(index, buf.get_ptr(), buf.size_in_bytes))

        # strip off Null Terminator
        return buf.read_str()

    def element_name_from_value(self, PropertyValue p_value):
        cdef lib.aafUInt32 size_in_bytes
        error_check(self.ptr.GetNameBufLenFromValue(p_value.ptr, &size_in_bytes))

        cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)

        buf.size_in_bytes = size_in_bytes

        error_check(self.ptr.GetNameFromValue(p_value.ptr, buf.get_ptr(), buf.size_in_bytes))

        # strip off Null Terminator
        return buf.read_str()

    def element_value(self, lib.aafUInt32 index):
        cdef lib.aafInt64 value
        error_check(self.ptr.GetElementValue(index, &value))
        return value

    def elements(self):
        d = {}

        for i in xrange(self.size()):
            name =self.element_name(i)
            value = self.element_value(i)
            d[name] = value
        return d

    def set_value(self, PropertyValue p_value, value):
        cdef lib.aafInt64 enum_value
        for key,enum_value in self.elements().items():
            if key.lower() == value.lower():
                error_check(self.ptr.SetIntegerValue(p_value.ptr, enum_value))
                return

        raise ValueError("Invalid TypeDefEnum Key %s" % value)

    def value(self, PropertyValue p_value):
        v = self.element_name_from_value(p_value)
        if v == "True":
            return True
        if v == "False":
            return False

        return v
