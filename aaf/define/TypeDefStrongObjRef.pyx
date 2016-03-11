cdef class TypeDefStrongObjRef(TypeDefObjectRef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefStrongObjRef

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefStrongObjRef)

        TypeDefObjectRef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, ClassDef classdef not None, AUID auid not None, name not None):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_meta_instance(self, lib.AUID_AAFTypeDefStrongObjRef)

        cdef AAFCharBuffer buf = AAFCharBuffer(name)

        error_check(self.ptr.Initialize(auid.get_auid(), classdef.ptr, buf.get_ptr()))

        dictionary.register_def(self)
