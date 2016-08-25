cimport lib
from .util cimport error_check, query_interface, register_object, AAFCharBuffer, aaf_integral

from .define cimport PropertyDef, TypeDef, TypeDefString, TypeDefInt, resolve_typedef, TypeDefString
from .dictionary cimport Dictionary

from libcpp.vector cimport vector
from libcpp.string cimport string
from wstring cimport  wstring, wideToString, toWideString

cdef class PropertyItem(AAFBase):

    def __init__(self, AAFBase obj = None):
        raise TypeError("This class cannot be instantiated from Python")

    def property_value(self):
        cdef lib.aafBoolean_t b
        cdef PropertyValue value

        error_check(self.parent.obj_ptr.IsPropertyPresent(self.property_def.ptr, &b))
        if b:
            value = PropertyValue.__new__(PropertyValue)
            error_check(self.parent.obj_ptr.GetPropertyValue(self.property_def.ptr, &value.ptr))
            value.query_interface()
            value.root = self.root
            return value
        else:
            return None

    property value:
        def __get__(self):

            cdef lib.aafBoolean_t b
            cdef PropertyValue value

            error_check(self.parent.obj_ptr.IsPropertyPresent(self.property_def.ptr, &b))

            if b:
                value = PropertyValue.__new__(PropertyValue)
                error_check(self.parent.obj_ptr.GetPropertyValue(self.property_def.ptr, &value.ptr))
                value.query_interface()
                value.root = self.root
                return value.value

            else:
                return None

        def __set__(self, value):
            cdef lib.aafBoolean_t b
            cdef PropertyValue p_value

            error_check(self.parent.obj_ptr.IsPropertyPresent(self.property_def.ptr, &b))

            if b:
                p_value = PropertyValue.__new__(PropertyValue)
                error_check(self.parent.obj_ptr.GetPropertyValue(self.property_def.ptr, &p_value.ptr))

            else:
                p_value = PropertyValue.__new__(PropertyValue)
                error_check(self.parent.obj_ptr.CreateOptionalPropertyValue(self.property_def.ptr, &p_value.ptr))

            p_value.query_interface()
            p_value = p_value.set_value(value)

            error_check(self.parent.obj_ptr.SetPropertyValue(self.property_def.ptr, p_value.ptr))

    property typedef:
        def __get__(self):
            return self.property_def.typedef()

    property name:
        def __get__(self):
            return self.property_def.name

    def __repr__(self):
        return '<%s.%s %s at 0x%x>' % (
                self.__class__.__module__,
                self.__class__.__name__,
                str(self.name),
                id(self),
                )

cdef class Property(AAFBase):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFProperty

    def __init__(self, AAFBase obj = None):
        raise TypeError("This class cannot be instantiated from Python")

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFProperty)

        AAFBase.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def property_def(self):
        cdef PropertyDef prop_def = PropertyDef.__new__(PropertyDef)
        error_check(self.ptr.GetDefinition(&prop_def.ptr))
        prop_def.query_interface()
        prop_def.root = self.root
        return prop_def

    def property_value(self):
        """
        returns PropertyValue object
        """
        cdef PropertyValue value = PropertyValue.__new__(PropertyValue)
        error_check(self.ptr.GetValue(&value.ptr))
        value.query_interface()
        value.root = self.root
        return value

    def value_typedef(self):
        value = self.property_value()
        return value.typedef()

    def __repr__(self):
        return '<%s.%s %s at 0x%x>' % (
                self.__class__.__module__,
                self.__class__.__name__,
                str(self.name),
                id(self),
                )

    property name:
        def __get__(self):
            d = self.property_def()
            return d.name
    property value:
        def __get__(self):
            return self.property_value().value
        def __set__(self, value):
            self.property_value().value = value



cdef class PropertyValue(AAFBase):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFPropertyValue

    def __init__(self, AAFBase obj = None):
        raise TypeError("This class cannot be instantiated from Python")

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFPropertyValue)

        AAFBase.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def typedef(self):
        cdef TypeDef type_def = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetType(&type_def.typedef_ptr))
        type_def.query_interface()
        type_def.root = self.root
        return resolve_typedef(type_def)

    def __repr__(self):
        return '<%s.%s %s at 0x%x>' % (
                self.__class__.__module__,
                self.__class__.__name__,
                str(self.typedef().name),
                id(self),
                )

    def set_value(self, value):
        typedef = self.typedef()
        result = typedef.set_value(self, value)
        if result:
            return result
        return self

    property defined_type:
        def __get__(self):
            cdef lib.aafBoolean_t b
            error_check(self.ptr.IsDefinedType(&b))
            return b == 1

    property value:
        def __get__(self):
            typedef = self.typedef()
            return typedef.value(self)

        def __set__(self, value):
            self.set_value(value)

cdef class TaggedValue(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTaggedValue
        self.auid = lib.AUID_AAFTaggedValue
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTaggedValue)

        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, name not None, value, typedef = "String"):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        if not isinstance(typedef, TypeDef):
            typedef = self.dictionary().lookup_typedef(typedef)

        if isinstance(typedef, TypeDefString):
            initialize_string_tagged_value(self, name, value)

        elif isinstance(typedef, TypeDefInt):
            initialize_int_tagged_value(self, name, value, typedef)

        else:
            raise NotImplementedError("Not implemented yet for: %s" % typedef.name)


    def typedef(self):
        cdef TypeDef type_def = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetTypeDefinition(&type_def.typedef_ptr))
        type_def.query_interface()
        type_def.root = self.root
        return resolve_typedef(type_def)

    property value:
        def __get__(self):
            return self['Value'].value
        def __set__(self, value):
            self['Value'].value = value

cdef initialize_string_tagged_value(TaggedValue tag, name, value):

    cdef TypeDef typedef = tag.dictionary().lookup_typedef("String")

    cdef AAFCharBuffer name_buf = AAFCharBuffer(name)
    cdef AAFCharBuffer value_buf = AAFCharBuffer(value)

    error_check(tag.ptr.Initialize(name_buf.get_ptr(),
                                   typedef.typedef_ptr,
                                   value_buf.size_in_bytes,
                                   <lib.aafDataBuffer_t > value_buf.get_ptr()))


cdef initialize_int_tagged_value(TaggedValue tag, name, value, TypeDefInt typedef):
    cdef lib.aafUInt32 size = typedef.size()
    if typedef.is_signed():
        if sizeof(lib.aafInt8) == size:
            init_aaf_integral_tagged_value[lib.aafInt8](tag, name, value, typedef)
        elif sizeof(lib.aafInt16) == size:
            init_aaf_integral_tagged_value[lib.aafInt16](tag, name, value, typedef)
        elif sizeof(lib.aafInt32) == size:
            init_aaf_integral_tagged_value[lib.aafInt32](tag, name, value, typedef)
        else:
            init_aaf_integral_tagged_value[lib.aafInt64](tag, name, value, typedef)
    else:
        if sizeof(lib.aafUInt8) == size:
            init_aaf_integral_tagged_value[lib.aafUInt8](tag, name, value, typedef)
        elif sizeof(lib.aafUInt16) == size:
            init_aaf_integral_tagged_value[lib.aafUInt16](tag, name, value, typedef)
        elif sizeof(lib.aafUInt32) == size:
            init_aaf_integral_tagged_value[lib.aafUInt32](tag, name, value, typedef)
        else:
            init_aaf_integral_tagged_value[lib.aafUInt64](tag, name, value, typedef)


cdef init_aaf_integral_tagged_value(TaggedValue tag, name,  aaf_integral value, TypeDefInt typedef):
    cdef AAFCharBuffer name_buf = AAFCharBuffer(name)

    error_check(tag.ptr.Initialize(name_buf.get_ptr(),  typedef.typedef_ptr,
                                   typedef.size(),  <lib.aafDataBuffer_t > &value))


register_object(TaggedValue)
