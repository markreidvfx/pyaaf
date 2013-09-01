cimport lib

from .util cimport error_check, query_interface, register_object

from base cimport AAFObject, AAFBase, AUID
from mob cimport Mob 
from metadef cimport TypeDef
from datadef cimport DataDef, OperationDef, ParameterDef
from iterator cimport ComponentIter, SegmentIter, ParamIter

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
    
    def datadef(self):
        cdef DataDef data_def = DataDef()
        error_check(self.comp_ptr.GetDataDef(&data_def.ptr))
        return DataDef(data_def)
        
    property length:
        def __get__(self):
            if self.has_key("Length"):
                return self['Length']
            return None
    property media_kind:
        def __get__(self):
            return self.datadef().name
            
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
            
cdef class Transition(Component):
    def __init__(self, AAFBase obj = None):
        super(Transition, self).__init__(obj)
        self.iid = lib.IID_IAAFTransition
        self.auid = lib.AUID_AAFTransition
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    property cutpoint:
        def __get__(self):
            cdef lib.aafPosition_t value
            error_check(self.ptr.GetCutPoint(&value))
            return value
            
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
    
cdef class Timecode(Segment):
    def __init__(self, AAFBase obj = None):
        super(Timecode, self).__init__(obj)
        self.iid = lib.IID_IAAFTimecode
        self.auid = lib.AUID_AAFTimecode
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class Filler(Segment):
    def __init__(self, AAFBase obj = None):
        super(Filler, self).__init__(obj)
        self.iid = lib.IID_IAAFFiller
        self.auid = lib.AUID_AAFFiller
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class Pulldown(Segment):
    def __init__(self, AAFBase obj = None):
        super(Pulldown, self).__init__(obj)
        self.iid = lib.IID_IAAFPulldown
        self.auid = lib.AUID_AAFPulldown
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

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
    
cdef class OperationGroup(Segment):
    def __init__(self, AAFBase obj = None):
        super(OperationGroup, self).__init__(obj)
        self.iid = lib.IID_IAAFOperationGroup
        self.auid = lib.AUID_AAFOperationGroup
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    def input_segments(self):
        cdef Segment seg
        for i in xrange(self.nb_input_segments):
            seg = Segment()
            error_check(self.ptr.GetInputSegmentAt(i, &seg.seg_ptr))
            yield Segment(seg).resolve()
    
    def operationdef(self):
        cdef OperationDef op_def = OperationDef()
        error_check(self.ptr.GetOperationDefinition(&op_def.ptr))
        return OperationDef(op_def)
    
    def parameters(self):
        cdef ParamIter param_iter = ParamIter()
        error_check(self.ptr.GetParameters(&param_iter.ptr))
        return param_iter
    
    property nb_input_segments:
        def __get__(self):
            cdef lib.aafUInt32 value
            error_check(self.ptr.CountSourceSegments(&value))
            return value
    
    property operation:
        def __get__(self):
            return self.operationdef().name
        
    
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
    
cdef class ScopeReference(Segment):
    def __init__(self, AAFBase obj = None):
        super(ScopeReference, self).__init__(obj)
        self.iid = lib.IID_IAAFScopeReference
        self.auid = lib.AUID_AAFScopeReference
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class EssenceGroup(Segment):
    """
    Describes multiple digital representations of the same original content source.
    """
    def __init__(self, AAFBase obj = None):
        super(EssenceGroup, self).__init__(obj)
        self.iid = lib.IID_IAAFEssenceGroup
        self.auid = lib.AUID_AAFEssenceGroup
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class Selector(Segment):
    """
    Provides the value of a single Segment while preserving references to unused alternatives.
    """
    def __init__(self, AAFBase obj = None):
        super(Selector, self).__init__(obj)
        self.iid = lib.IID_IAAFSelector
        self.auid = lib.AUID_AAFSelector
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class EdgeCode(Segment):
    def __init__(self, AAFBase obj = None):
        super(EdgeCode, self).__init__(obj)
        self.iid = lib.IID_IAAFEdgecode
        self.auid = lib.AUID_AAFEdgecode
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class Event(Segment):
    def __init__(self, AAFBase obj = None):
        super(Event, self).__init__(obj)
        self.iid = lib.IID_IAAFEvent
        self.auid = lib.AUID_AAFEvent
        self.event_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.event_ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.event_ptr
    
    def __dealloc__(self):
        if self.event_ptr:
            self.event_ptr.Release()
            
cdef class CommentMarker(Event):
    def __init__(self, AAFBase obj = None):
        super(CommentMarker, self).__init__(obj)
        self.iid = lib.IID_IAAFCommentMarker
        self.auid = lib.AUID_AAFCommentMarker
        self.comment_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.comment_ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.comment_ptr
    
    def __dealloc__(self):
        if self.comment_ptr:
            self.comment_ptr.Release()
            
cdef class DescriptiveMarker(CommentMarker):
    def __init__(self, AAFBase obj = None):
        super(DescriptiveMarker, self).__init__(obj)
        self.iid = lib.IID_IAAFDescriptiveMarker
        self.auid = lib.AUID_AAFDescriptiveMarker
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class Parameter(AAFObject):
    """
    A Parameter is an effect control. They are only on OperationGroups.
    """
    def __init__(self, AAFBase obj = None):
        super(Parameter, self).__init__(obj)
        self.iid = lib.IID_IAAFParameter
        self.auid = lib.AUID_AAFParameter
        self.param_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.param_ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.param_ptr
    
    def __dealloc__(self):
        if self.param_ptr:
            self.param_ptr.Release()
    
    def typedef(self):
        cdef TypeDef type_def = TypeDef()
        error_check(self.param_ptr.GetTypeDefinition(&type_def.typedef_ptr))
        return TypeDef(type_def).resolve()
        
    def parameterdef(self):
        cdef ParameterDef param_def = ParameterDef()
        error_check(self.param_ptr.GetParameterDefinition(&param_def.ptr))
        return ParameterDef(param_def)
    
    property name:
        def __get__(self):
            param_def = self.parameterdef()
            return param_def.name
        
    property value:
        def __get__(self):
            props = list(self.properties())
            if len(props) == 2:
                return props[1].value
            values = []
            for p in props[1:]:
                values.append(p.value)
            return values
            
        
            
cdef class ConstantValue(Parameter):
    def __init__(self, AAFBase obj = None):
        super(ConstantValue, self).__init__(obj)
        self.iid = lib.IID_IAAFConstantValue
        self.auid = lib.AUID_AAFConstantValue
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class VaryingValue(Parameter):
    def __init__(self, AAFBase obj = None):
        super(VaryingValue, self).__init__(obj)
        self.iid = lib.IID_IAAFVaryingValue
        self.auid = lib.AUID_AAFVaryingValue
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class ControlPoint(AAFObject):
    def __init__(self, AAFBase obj = None):
        super(ControlPoint, self).__init__(obj)
        self.iid = lib.IID_IAAFControlPoint
        self.auid = lib.AUID_AAFControlPoint
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
register_object(Component)
register_object(Segment)
register_object(Transition)
register_object(Sequence)
register_object(Timecode)
register_object(Filler)
register_object(Pulldown)
register_object(SourceReference)
register_object(SourceClip)
register_object(OperationGroup)
register_object(NestedScope)
register_object(ScopeReference)
register_object(EssenceGroup)
register_object(Selector)
register_object(EdgeCode)
register_object(Event)
register_object(CommentMarker)
register_object(DescriptiveMarker)
register_object(Parameter)
register_object(ConstantValue)
register_object(VaryingValue)
register_object(ControlPoint)
