cimport lib

from libc.string cimport memset 

from .util cimport error_check, query_interface, register_object, fraction_to_aafRational, aafRational_to_fraction, AUID, MobID

from .base cimport AAFObject, AAFBase
from .mob cimport Mob 
from .define cimport TypeDef, DataDef, OperationDef, ParameterDef, InterpolationDef
from .iterator cimport ComponentIter, ControlPointIter, SegmentIter, ParamIter
from .mob cimport Mob

from libcpp.vector cimport vector

cdef class Component(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFComponent
        self.auid = lib.AUID_AAFComponent
        self.comp_ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.comp_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.comp_ptr, lib.IID_IAAFComponent)

        AAFObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.comp_ptr:
            self.comp_ptr.Release()
    
    def datadef(self):
        cdef DataDef data_def = DataDef.__new__(DataDef)
        error_check(self.comp_ptr.GetDataDef(&data_def.ptr))
        data_def.query_interface()
        return data_def.resolve()
        
    property length:
        def __get__(self):
            if self.has_key("Length"):
                return self['Length'].value
            return None
        def __set__(self, lib.aafLength_t value):
            error_check(self.comp_ptr.SetLength(value))
            
    property media_kind:
        def __get__(self):
            return self.datadef().name
        def __set__(self, bytes value):
            cdef DataDef data_def = self.dictionary().lookup_datadef(value)
            self.comp_ptr.SetDataDef(data_def.ptr)
            
cdef class Segment(Component):
    def __cinit__(self):
        self.iid = lib.IID_IAAFSegment
        self.auid = lib.AUID_AAFSegment
        self.seg_ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.seg_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.seg_ptr, lib.IID_IAAFSegment)

        Component.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.seg_ptr:
            self.seg_ptr.Release()
            
cdef class Transition(Component):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTransition
        self.auid = lib.AUID_AAFTransition
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTransition)

        Component.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    property cutpoint:
        def __get__(self):
            cdef lib.aafPosition_t value
            error_check(self.ptr.GetCutPoint(&value))
            return value
            
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
            
    def initialize(self, bytes media_kind):
        cdef DataDef media_datadef        
        media_datadef = self.dictionary().lookup_datadef(media_kind)
        error_check(self.ptr.Initialize(media_datadef.ptr))
        
    def components(self):
        cdef ComponentIter comp_inter = ComponentIter.__new__(ComponentIter)
        error_check(self.ptr.GetComponents(&comp_inter.ptr))
        return comp_inter
    
    def append(self, Component component):
        error_check(self.ptr.AppendComponent(component.comp_ptr))
        
    
cdef class Timecode(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTimecode
        self.auid = lib.AUID_AAFTimecode
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTimecode)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def initialize(self, lib.aafLength_t length, 
                   lib.aafFrameOffset_t start_frame, 
                   lib.aafUInt16 fps,
                   drop = False):

        cdef lib.aafTimecode_t timecode
        timecode.startFrame = start_frame
        if drop:
            timecode.drop = lib.kAAFTcDrop
        else:
            timecode.drop = lib.kAAFTcNonDrop
        timecode.fps = fps
        
        error_check(self.ptr.Initialize(length, &timecode))
        
cdef class Filler(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFFiller
        self.auid = lib.AUID_AAFFiller
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFFiller)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def initialize(self, media_kind, lib.aafLength_t length):
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)
        
        error_check(self.ptr.Initialize(data_def.ptr, length))
            
cdef class Pulldown(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFPulldown
        self.auid = lib.AUID_AAFPulldown
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFPulldown)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def initialize(self, media_kind):
        self.media_kind = media_kind
        
    property kind:
        def __get__(self):
            return self['PulldownKind'].value
        def __set__(self, bytes value):
            self['PulldownKind'].value = value
        
    property direction:
        def __get__(self):
            return self['PulldownDirection'].value
        def __set__(self, bytes value):
            self['PulldownDirection'].value = value
    
    property phase:
        def __get__(self):
            return self['PhaseFrame'].value
        def __set__(self, lib.aafPhaseFrame_t value):
            self['PhaseFrame'].value = value
    
    
    property segment:
        def __get__(self):
            cdef Segment seg = Segment.__new__(Segment)
            error_check(self.ptr.GetInputSegment(&seg.seg_ptr))
            seg.query_interface()
            return seg.resolve()
        def __set__(self, Segment value):
            error_check(self.ptr.SetInputSegment(value.seg_ptr))

cdef class SourceReference(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFSourceReference
        self.auid = lib.AUID_AAFSourceReference
        self.ref_ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ref_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ref_ptr, lib.IID_IAAFSourceReference)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ref_ptr:
            self.ref_ptr.Release()
            
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
        return mob.resolve()
    
class ParametersHelper(object):
    def __init__(self, obj):
        self.obj = obj
        
    def __getitem__(self, bytes index):
        for p in self.obj.parameters():
            if p.name == index:
                return p
        raise KeyError("Key %s not found" % index)
    def keys(self):
        """
        Return a list of the parameter names
        """
        return [p.name for p in self.obj.parameters()]
    
    def has_key(self, bytes key):
        """
        Test for the presence of key in the parameter names
        """
        if key in self.keys():
            return True
        return False
    
    def get(self, key, default=None):
        """
        Return the parameter for key if key is in the obj, else default. 
        If default is not given, it defaults to None, so that this method never raises a KeyError.
        """
        if self.has_key(key):
            return self[key]
        return default
    
cdef class OperationGroup(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFOperationGroup
        self.auid = lib.AUID_AAFOperationGroup
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFOperationGroup)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def input_segments(self):
        cdef Segment seg
        for i in xrange(self.nb_input_segments):
            seg = Segment.__new__(Segment)
            error_check(self.ptr.GetInputSegmentAt(i, &seg.seg_ptr))
            seg.query_interface()
            yield seg.resolve()
    
    def operationdef(self):
        cdef OperationDef op_def = OperationDef.__new__(OperationDef)
        error_check(self.ptr.GetOperationDefinition(&op_def.ptr))
        op_def.query_interface()
        return op_def
    
    def parameters(self):
        cdef ParamIter param_iter = ParamIter.__new__(ParamIter)
        error_check(self.ptr.GetParameters(&param_iter.ptr))
        return param_iter
    
    property parameter:
        def __get__(self):
            helper = ParametersHelper(self)
            return helper
    
    property nb_input_segments:
        def __get__(self):
            cdef lib.aafUInt32 value
            error_check(self.ptr.CountSourceSegments(&value))
            return value
    
    property operation:
        def __get__(self):
            return self.operationdef().name
        
    
cdef class NestedScope(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFNestedScope
        self.auid = lib.AUID_AAFNestedScope
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFNestedScope)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def segments(self):
        cdef SegmentIter seg_iter = SegmentIter.__new__(SegmentIter)
        error_check(self.ptr.GetSegments(&seg_iter.ptr))
        return seg_iter
    
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

cdef class EssenceGroup(Segment):
    """
    Describes multiple digital representations of the same original content source.
    """
    def __cinit__(self):
        self.iid = lib.IID_IAAFEssenceGroup
        self.auid = lib.AUID_AAFEssenceGroup
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFEssenceGroup)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class Selector(Segment):
    """
    Provides the value of a single Segment while preserving references to unused alternatives.
    """
    def __cinit__(self):
        self.iid = lib.IID_IAAFSelector
        self.auid = lib.AUID_AAFSelector
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFSelector)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class EdgeCode(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFEdgecode
        self.auid = lib.AUID_AAFEdgecode
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFEdgecode)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class Event(Segment):
    def __cinit__(self, AAFBase obj = None):
        self.iid = lib.IID_IAAFEvent
        self.auid = lib.AUID_AAFEvent
        self.event_ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.event_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.event_ptr, lib.IID_IAAFEvent)

        Segment.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.event_ptr:
            self.event_ptr.Release()
            
cdef class CommentMarker(Event):
    def __cinit__(self):
        self.iid = lib.IID_IAAFCommentMarker
        self.auid = lib.AUID_AAFCommentMarker
        self.comment_ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.comment_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.comment_ptr, lib.IID_IAAFCommentMarker)

        Event.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.comment_ptr:
            self.comment_ptr.Release()
            
cdef class DescriptiveMarker(CommentMarker):
    def __cinit__(self):
        self.iid = lib.IID_IAAFDescriptiveMarker
        self.auid = lib.AUID_AAFDescriptiveMarker
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFDescriptiveMarker)

        CommentMarker.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class Parameter(AAFObject):
    """
    A Parameter is an effect control. They are only on OperationGroups.
    """
    def __cinit__(self):
        self.iid = lib.IID_IAAFParameter
        self.auid = lib.AUID_AAFParameter
        self.param_ptr = NULL
        
    def __init__(self, AAFBase obj = None):
        if not obj:
            return
        
        self.query_interface(obj)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.param_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.param_ptr, lib.IID_IAAFParameter)

        AAFObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.param_ptr:
            self.param_ptr.Release()
    
    def typedef(self):
        cdef TypeDef type_def = TypeDef.__new__(TypeDef)
        error_check(self.param_ptr.GetTypeDefinition(&type_def.typedef_ptr))
        type_def.query_interface()
        return type_def.resolve()
        
    def parameterdef(self):
        cdef ParameterDef param_def = ParameterDef.__new__(ParameterDef)
        error_check(self.param_ptr.GetParameterDefinition(&param_def.ptr))
        param_def.query_interface()
        return param_def
    
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
    def __cinit__(self):
        self.iid = lib.IID_IAAFConstantValue
        self.auid = lib.AUID_AAFConstantValue
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFConstantValue)

        Parameter.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class VaryingValue(Parameter):
    def __cinit__(self):
        self.iid = lib.IID_IAAFVaryingValue
        self.auid = lib.AUID_AAFVaryingValue
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFVaryingValue)

        Parameter.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def interpolation_def(self):
        cdef InterpolationDef inter_def = InterpolationDef.__new__(InterpolationDef)
        error_check(self.ptr.GetInterpolationDefinition(&inter_def.ptr))
        inter_def.query_interface()
        return inter_def.resolve()
    
    def count(self):
        cdef lib.aafUInt32 value
        error_check(self.ptr.CountControlPoints(&value))
        return value
            
    def points(self):
        cdef ControlPointIter iter = ControlPointIter.__new__(ControlPointIter)
        error_check(self.ptr.GetControlPoints(&iter.ptr))
        return iter
        
            
    def value_at(self, time):
        """
        Get the varying value at a specified time, Only currently works for step and linear interpolation.
        """

        interp_def = self.interpolation_def()
        
        if not interp_def.name in ('LinearInterp', 'StepInterp'):
            raise NotImplementedError("value_at not implemented for %s" % interp_def.name)
        
        
        cdef lib.aafInt32 buffer_size
        
        error_check(self.ptr.GetValueBufLen(&buffer_size))
        
        cdef lib.aafRational_t time_t
        cdef lib.aafRational_t value_t
        
        cdef lib.aafInt32 bytes_read
        
        fraction_to_aafRational(time, time_t)
        
        error_check(self.ptr.GetInterpolatedValue(time_t,
                                                  sizeof(value_t),
                                                  <lib.aafDataBuffer_t> &value_t,
                                                  &bytes_read
                                                  ))
        if bytes_read != sizeof(value_t):
            raise IOError("invalid read size")
        
        return aafRational_to_fraction(value_t)
    
            
cdef class ControlPoint(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFControlPoint
        self.auid = lib.AUID_AAFControlPoint
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFControlPoint)

        AAFObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def typedef(self):
        cdef TypeDef type_def = TypeDef.__new__(TypeDef)
        error_check(self.ptr.GetTypeDefinition(&type_def.typedef_ptr))
        type_def.query_interface()
        return type_def.resolve()

    def point_properties(self):
        prop = self.get('ControlPointPointProperties', None)
        if prop:
            return prop.value
        return []
    
    property time:
        def __get__(self):
            return self['Time'].value
        def __set__(self, value):
            cdef lib.aafRational_t value_t
            fraction_to_aafRational(value, value_t)
            error_check(self.ptr.SetTime(value_t))
        
    property value:
        def __get__(self):
            return self['Value'].value
    
    property edit_hint:
        def __get__(self):
            return self['EditHint'].value
             
        
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
