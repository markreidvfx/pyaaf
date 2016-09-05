cdef class TypeDefString(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefString

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefString)

        TypeDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, AUID auid not None, name not None, TypeDef element_typedef = None):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_meta_instance(self, lib.AUID_AAFTypeDefString)
        if element_typedef is None:
            element_typedef = dictionary.lookup_typedef("Character")

        cdef AAFCharBuffer aafchar_buf = AAFCharBuffer(name)

        error_check(self.ptr.Initialize(auid.auid, element_typedef.typedef_ptr, aafchar_buf.get_ptr()))

    def typedef(self):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetType(&typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(TypeDef(typedef))

    def set_value(self, PropertyValue p_value, value):

        cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)

        buf.write_str(value)
        buf.null_terminate()
        error_check(self.ptr.SetCString(p_value.ptr,
                                        <lib.aafMemPtr_t> buf.get_ptr(),
                                        buf.size_in_bytes))

    def get_value(self, PropertyValue p_value):

        cdef lib.aafUInt32 size_in_chars
        error_check(self.ptr.GetCount(p_value.ptr, &size_in_chars))

        cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)

        buf.size = size_in_chars

        error_check(self.ptr.GetElements(p_value.ptr, <lib.aafMemPtr_t> buf.get_ptr(), buf.size_in_bytes))

        # strip off Null Terminator
        return buf.read_str()

    def value(self, PropertyValue p_value):
        return self.get_value(p_value)
