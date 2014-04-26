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
            
    def __init__(self, root, bytes media_kind, lib.aafLength_t length, SourceRef source_ref):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)
        
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)
        
        error_check(self.ptr.Initialize(data_def.ptr, length, source_ref.get_aafSourceRef_t()))
        
    
    def initialize(self, Mob mob =None, lib.aafSlotID_t slotID = 0, 
                      lib.aafLength_t length = 0, lib.aafPosition_t start_time = 0,
                      bytes media_kind = None):
        
        cdef lib.aafSourceRef_t source_ref
        
        cdef MobID mobID
        cdef DataDef data_def
        
        if mob:
        
            mobID = mob.mobID
            source_ref.sourceID = mobID.mobID
            source_ref.sourceSlotID = slotID
            source_ref.startTime = start_time
            
            slot = mob.slot_at(slotID)
            data_def = slot.datadef()
        
        else:
            # no predecesor - AAF spec. says null aafSourceRef_t for this
            memset(&source_ref,0 , sizeof(source_ref))
            data_def = self.dictionary().lookup_datadef(media_kind)
        
        error_check(self.ptr.Initialize(data_def.ptr,
                                        length,
                                        source_ref
                                        ))
            
    def resolve_ref(self):
        cdef Mob mob = Mob.__new__(Mob)
        error_check(self.ptr.ResolveRef(&mob.ptr))
        mob.query_interface()
        mob.root = self.root
        return mob.resolve()