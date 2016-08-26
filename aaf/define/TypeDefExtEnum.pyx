cdef class TypeDefExtEnum(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefExtEnum

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefExtEnum)

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

    def elment_name_from_auid(self, AUID auid):
        cdef lib.aafUInt32 size_in_bytes

        error_check(self.ptr.GetNameBufLenFromAUID(auid.auid, &size_in_bytes))

        cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)
        buf.size_in_bytes = size_in_bytes

        error_check(self.ptr.GetNameFromAUID(auid.auid, buf.get_ptr(), buf.size_in_bytes))

        # strip off Null Terminator
        return buf.read_str()

    def element_value(self, lib.aafUInt32 index):

        cdef AUID auid = AUID()
        error_check(self.ptr.GetElementValue(index, &auid.auid))
        return auid

    def elements(self):
        d = {}
        for i in xrange(self.size()):
            name = self.element_name(i)
            value = self.element_value(i)
            d[name]= value
        return d

    def auid_value(self, PropertyValue p_value):
        cdef AUID auid = AUID()
        error_check(self.ptr.GetAUIDValue(p_value.ptr, &auid.auid))
        return auid

    def value(self, PropertyValue p_value):
        return self.element_name_from_value(p_value)

    def set_value(self, PropertyValue p_value, value):
        cdef AUID auid
        cdef PropertyValue out_value

        cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)
        buf.write_str(value)

        for name, auid in self.elements().items():

            if name == value:
                error_check(self.ptr.SetAUIDValue(p_value.ptr, auid.auid))
                return

        raise ValueError("Invalid TypeDefExtEnum Key %s" % value)
