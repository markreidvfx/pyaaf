cdef class SourceClip(SourceReference):
    def __cinit__(self):
        self.iid = lib.IID_IAAFSourceClip
        self.auid = lib.AUID_AAFSourceClip
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFSourceClip)

        SourceReference.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def __init__(self, root, bytes media_kind, lib.aafLength_t length, SourceRef source_ref = None):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)
        
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)
        
        cdef lib.aafSourceRef_t source_ref_t
        
        if source_ref:
            source_ref_t = source_ref.get_aafSourceRef_t()
        else:
            memset(&source_ref_t,0 , sizeof(source_ref))
        
        
        error_check(self.ptr.Initialize(data_def.ptr, length, source_ref_t))
        
            
    def resolve_ref(self):
        cdef Mob mob = Mob.__new__(Mob)
        error_check(self.ptr.ResolveRef(&mob.ptr))
        mob.query_interface()
        mob.root = self.root
        return mob.resolve()