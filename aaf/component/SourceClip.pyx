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
            
    def __init__(self, root, media_kind, lib.aafLength_t length = 0, SourceRef source_ref = None):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)
        
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)
        
        if source_ref is None:
            source_ref = SourceRef()
            
        error_check(self.ptr.Initialize(data_def.ptr, length, source_ref.get_aafSourceRef_t()))
        
            
    def resolve_ref(self):
        cdef Mob mob = Mob.__new__(Mob)
        error_check(self.ptr.ResolveRef(&mob.ptr))
        mob.query_interface()
        mob.root = self.root
        return mob.resolve()
    
    def resolve_slot(self):
        mob = self.resolve_ref()
        if mob:
            return mob.slot_at(self.source_ref.slot_id)
    
    property start_time:
        def __get__(self):
            return self.source_ref.start_time
        
        def __set__(self, value):
            source_ref = self.source_ref
            source_ref.start_time = value
            self.source_ref = source_ref
    
    property source_ref:
        
        def __get__(self):
            cdef SourceRef value = SourceRef.__new__(SourceRef)
            error_check(self.ptr.GetSourceReference(&value.source_ref))
            return value
            
        def __set__(self, SourceRef value):
            
            error_check(self.ptr.SetSourceReference(value.get_aafSourceRef_t()))
            