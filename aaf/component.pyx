cimport lib

from .util cimport error_check, query_interface, register_object

from base cimport AAFObject, AAFBase, AUID
from mob cimport Mob 
from datadef cimport DataDef
from iterator cimport ComponentIter, SegmentIter

cdef class Component(AAFObject):
    def __init__(self, AAFBase obj = None):
        super(Component, self).__init__(obj)
        self.iid = lib.IID_IAAFComponent
        self.auid = lib.AUID_AAFComponent
        self.comp_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.comp_ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.comp_ptr
    
    def __dealloc__(self):
        if self.comp_ptr:
            self.comp_ptr.Release()
            
    property length:
        def __get__(self):
            cdef lib.aafLength_t length
            error_check(self.comp_ptr.GetLength(&length))
            return length
            
            
cdef class Segment(Component):
    def __init__(self, AAFBase obj = None):
        super(Segment, self).__init__(obj)
        self.iid = lib.IID_IAAFSegment
        self.auid = lib.AUID_AAFSegment
        self.seg_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.seg_ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.seg_ptr
    
    def __dealloc__(self):
        if self.seg_ptr:
            self.seg_ptr.Release()
            
cdef class Sequence(Segment):
    def __init__(self, AAFBase obj = None):
        super(Sequence, self).__init__(obj)
        self.iid = lib.IID_IAAFSequence
        self.auid = lib.AUID_AAFSequence
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def initialize(self, bytes media_kind):
        cdef DataDef media_datadef        
        media_datadef = self.dictionary().lookup_datadef(media_kind)
        error_check(self.ptr.Initialize(media_datadef.ptr))
        
    def components(self):
        cdef ComponentIter comp_inter = ComponentIter()
        error_check(self.ptr.GetComponents(&comp_inter.ptr))
        return comp_inter

cdef class SourceReference(Segment):
    def __init__(self, AAFBase obj = None):
        super(SourceReference, self).__init__(obj)
        self.iid = lib.IID_IAAFSourceReference
        self.auid = lib.AUID_AAFSourceReference
        self.ref_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ref_ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ref_ptr
    
    def __dealloc__(self):
        if self.ref_ptr:
            self.ref_ptr.Release()
            
cdef class SourceClip(SourceReference):
    def __init__(self, AAFBase obj = None):
        super(SourceReference, self).__init__(obj)
        self.iid = lib.IID_IAAFSourceClip
        self.auid = lib.AUID_AAFSourceClip
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def resolve_ref(self):
        cdef Mob mob = Mob()
        error_check(self.ptr.ResolveRef(&mob.ptr))
        return Mob(mob).resolve()
    
cdef class NestedScope(Segment):
    def __init__(self, AAFBase obj = None):
        super(NestedScope, self).__init__(obj)
        self.iid = lib.IID_IAAFNestedScope
        self.auid = lib.AUID_AAFNestedScope
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def segments(self):
        cdef SegmentIter seg_iter = SegmentIter()
        error_check(self.ptr.GetSegments(&seg_iter.ptr))
        return seg_iter
    
register_object(Component)
register_object(Segment)
register_object(Sequence)
register_object(SourceReference)
register_object(SourceClip)
register_object(NestedScope)