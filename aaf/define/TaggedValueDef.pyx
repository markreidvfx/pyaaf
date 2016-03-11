cdef class TaggedValueDef(DefObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTaggedValueDefinition
        self.auid = lib.AUID_AAFTaggedValueDefinition
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTaggedValueDefinition)

        DefObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, auid, name, description):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        cdef AUID auid_obj = AUID(auid)

        cdef AAFCharBuffer name_buf = AAFCharBuffer(name)
        cdef AAFCharBuffer description_buf = AAFCharBuffer(name)

        error_check(self.ptr.Initialize(auid_obj.get_auid(), name_buf.get_ptr(), description_buf.get_ptr()))
