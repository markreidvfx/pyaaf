cdef class TypeDefInt(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefInt

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefInt)

        TypeDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def size(self):
        cdef lib.aafUInt32 size
        error_check(self.ptr.GetSize(&size))
        return size

    def is_signed(self):
        cdef lib.aafBoolean_t sign
        error_check(self.ptr.IsSigned(&sign))
        return bool(sign)

    def create_property_value(self, value):
        cdef lib.aafUInt32 size = self.size()

        cdef PropertyValue property_value = PropertyValue.__new__(PropertyValue)

        if self.is_signed():
            if sizeof(lib.aafInt8) == size:
                create_int_property_value[lib.aafInt8](self, property_value, value)
            elif sizeof(lib.aafInt16) == size:
                create_int_property_value[lib.aafInt16](self, property_value, value)
            elif sizeof(lib.aafInt32) == size:
                create_int_property_value[lib.aafInt32](self, property_value, value)
            else:
                create_int_property_value[lib.aafInt64](self, property_value, value)
        else:
            if sizeof(lib.aafUInt8) == size:
                create_int_property_value[lib.aafUInt8](self, property_value, value)
            elif sizeof(lib.aafUInt16) == size:
                create_int_property_value[lib.aafUInt16](self, property_value, value)
            elif sizeof(lib.aafUInt32) == size:
                create_int_property_value[lib.aafUInt32](self, property_value, value)
            else:
                create_int_property_value[lib.aafUInt64](self, property_value, value)

        property_value.query_interface()
        property_value.root = self.root

        return property_value

    def set_value(self, PropertyValue p_value, value):

        cdef lib.aafUInt32 size = self.size()
        if self.is_signed():
            if sizeof(lib.aafInt8) == size:
                set_int[lib.aafInt8](self, p_value, value)
            elif sizeof(lib.aafInt16) == size:
                set_int[lib.aafInt16](self, p_value, value)
            elif sizeof(lib.aafInt32) == size:
                set_int[lib.aafInt32](self, p_value, value)
            else:
                set_int[lib.aafInt64](self, p_value, value)
        else:
            if sizeof(lib.aafUInt8) == size:
                set_int[lib.aafUInt8](self, p_value, value)
            elif sizeof(lib.aafUInt16) == size:
                set_int[lib.aafUInt16](self, p_value, value)
            elif sizeof(lib.aafUInt32) == size:
                set_int[lib.aafUInt32](self, p_value, value)
            else:
                set_int[lib.aafUInt64](self, p_value, value)
        if value != self.value(p_value):
            raise ValueError("unable to set value")

    def get_value(self, PropertyValue p_value ):

        cdef lib.aafUInt32 size = self.size()
        if self.is_signed():
            if sizeof(lib.aafInt8) == size:
                return get_int[lib.aafInt8](self, p_value, 0)
            elif sizeof(lib.aafInt16) == size:
                return get_int[lib.aafInt16](self, p_value, 0)
            elif sizeof(lib.aafInt32) == size:
                return get_int[lib.aafInt32](self, p_value, 0)
            else:
                return get_int[lib.aafInt64](self, p_value, 0)
        else:
            if sizeof(lib.aafUInt8) == size:
                return get_int[lib.aafUInt8](self, p_value, 0)
            elif sizeof(lib.aafUInt16) == size:
                return get_int[lib.aafUInt16](self, p_value, 0)
            elif sizeof(lib.aafUInt32) == size:
                return get_int[lib.aafUInt32](self, p_value, 0)
            else:
                return get_int[lib.aafUInt64](self, p_value, 0)

    def value(self, PropertyValue p_value ):
        return self.get_value(p_value)

cdef aaf_integral create_int_property_value(TypeDefInt typdef, PropertyValue value, aaf_integral i):
    error_check(typdef.ptr.CreateValue( <lib.aafMemPtr_t>&i, sizeof(aaf_integral), &value.ptr))

cdef aaf_integral get_int(TypeDefInt typdef, PropertyValue value,aaf_integral i):
    error_check(typdef.ptr.GetInteger(value.ptr,
                                       <lib.aafMemPtr_t>&i,
                                       sizeof(aaf_integral)))

    return i

cdef aaf_integral set_int(TypeDefInt typdef, PropertyValue value,aaf_integral i):
    error_check(typdef.ptr.SetInteger(value.ptr,
                                       <lib.aafMemPtr_t>&i,
                                       sizeof(aaf_integral)))
