cdef class ScopeReference(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFScopeReference
        self.auid = lib.AUID_AAFScopeReference
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFScopeReference)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, media_kind, lib.aafUInt32 scope = 0, lib.aafUInt32 relative_slot = 0 ):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)
        error_check(self.ptr.Initialize(data_def.ptr, scope, relative_slot))
