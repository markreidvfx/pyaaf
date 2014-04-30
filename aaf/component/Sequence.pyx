cdef class Sequence(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFSequence
        self.auid = lib.AUID_AAFSequence
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFSequence)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def __init__(self, root, media_kind not None):
        
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)
        
        cdef DataDef media_datadef        
        media_datadef = self.dictionary().lookup_datadef(media_kind)
        error_check(self.ptr.Initialize(media_datadef.ptr))
        
    def components(self):
        cdef ComponentIter comp_inter = ComponentIter.__new__(ComponentIter)
        error_check(self.ptr.GetComponents(&comp_inter.ptr))
        comp_inter.root = self.root
        return comp_inter
    
    def append(self, Component component):
        error_check(self.ptr.AppendComponent(component.comp_ptr))