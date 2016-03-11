

cdef class CompositionMob(Mob):
    def __cinit__(self):
        self.iid = lib.IID_IAAFCompositionMob2
        self.auid = lib.AUID_AAFCompositionMob
        self.compositionmob_ptr = NULL
        self.compositionmob2_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.compositionmob_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.compositionmob_ptr, lib.IID_IAAFCompositionMob)

        if not self.compositionmob2_ptr:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.compositionmob2_ptr, lib.IID_IAAFCompositionMob2)

        Mob.query_interface(self, obj)

    def __init__(self, root,  name = None):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        if not name:
            name = b"composition mob"

        cdef AAFCharBuffer name_buf = AAFCharBuffer(name)

        error_check(self.compositionmob_ptr.Initialize(name_buf.get_ptr()))

    def __dealloc__(self):
        if self.compositionmob_ptr:
            self.compositionmob_ptr.Release()
        if self.compositionmob2_ptr:
            self.compositionmob2_ptr.Release()
