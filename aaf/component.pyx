cimport lib

from libc.string cimport memset, memcpy

from .util cimport error_check, query_interface, register_object, fraction_to_aafRational, aafRational_to_fraction, AUID, MobID, SourceRef
cimport util
from .base cimport AAFObject, AAFBase
from .mob cimport Mob
from .define cimport TypeDef, DataDef, OperationDef, ParameterDef, InterpolationDef, EdgeTypeMap, FilmTypeMap
from .iterator cimport ComponentIter, ControlPointIter, SegmentIter, ParamIter
from .mob cimport Mob
from .dictionary cimport Dictionary

from libcpp.vector cimport vector

include "component/Component.pyx"
include "component/Segment.pyx"
include "component/Transition.pyx"
include "component/Sequence.pyx"
include "component/Timecode.pyx"
include "component/TimecodeStream.pyx"
include "component/TimecodeStream12M.pyx"
include "component/Filler.pyx"
include "component/Pulldown.pyx"
include "component/SourceReference.pyx"
include "component/SourceClip.pyx"
include "component/OperationGroup.pyx"
include "component/NestedScope.pyx"
include "component/ScopeReference.pyx"
include "component/EssenceGroup.pyx"
include "component/Selector.pyx"
include "component/EdgeCode.pyx"
include "component/Event.pyx"
include "component/CommentMarker.pyx"
include "component/DescriptiveMarker.pyx"

include "component/Parameter.pyx"
include "component/ConstantValue.pyx"
include "component/VaryingValue.pyx"
include "component/ControlPoint.pyx"


register_object(Component)
register_object(Segment)
register_object(Transition)
register_object(Sequence)
register_object(Timecode)
register_object(TimecodeStream)
register_object(TimecodeStream12M)
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
