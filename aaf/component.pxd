cimport lib

from base cimport AAFObject

cdef class Component(AAFObject):
    cdef lib.IAAFComponent *comp_ptr
    
cdef class Segment(Component):
    cdef lib.IAAFSegment *seg_ptr
    
cdef class Transition(Component):
    pass
    
cdef class Sequence(Segment):
    cdef lib.IAAFSequence *ptr
    
cdef class Timecode(Segment):
    pass

cdef class Filler(Segment):
    pass

cdef class Pulldown(Segment):
    pass

cdef class SourceReference(Segment):
    cdef lib.IAAFSourceReference *ref_ptr

cdef class SourceClip(SourceReference):
    cdef lib.IAAFSourceClip *ptr
    
cdef class OperationGroup(Segment):
    cdef lib.IAAFOperationGroup *ptr

cdef class NestedScope(Segment):
    cdef lib.IAAFNestedScope *ptr

cdef class ScopeReference(Segment):
    pass

cdef class EssenceGroup(Segment):
    pass
    
cdef class Selector(Segment):
    pass
    
cdef class Edgecode(Segment):
    pass
    
cdef class Event(Segment):
    pass
    
cdef class CommentMarker(Event):
    pass
    
cdef class DescriptiveMarker(CommentMarker):
    pass

cdef class GPITrigger(Event):
    pass
    
cdef class TimecodeStream(Segment):
    pass
    
cdef class TimecodeStream12M(TimecodeStream):
    pass