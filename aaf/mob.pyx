cimport lib
from base cimport AAFObject, AAFBase

from libcpp.vector cimport vector
from libcpp.string cimport string
from cpython cimport bool

from libc.stdio cimport FILE, fopen, fclose, fread

from .util cimport error_check, query_interface, register_object, fraction_to_aafRational, SourceRef, Timecode, AUID, MobID, AAFCharBuffer
from .iterator cimport MobSlotIter, TaggedValueIter
from .component cimport Segment
from .essence cimport EssenceDescriptor, Locator, EssenceAccess
from .component cimport Segment
from .define cimport DataDef, CodecDefMap, ContainerDefMap, PullDownKindMap, PulldownDirMap
from .property cimport TaggedValue
from .dictionary cimport Dictionary

from wstring cimport wstring, wideToString, toWideString

from struct import unpack

from .fraction_util import AAFFraction

include "mob/Mob.pyx"
include "mob/MasterMob.pyx"
include "mob/CompositionMob.pyx"
include "mob/SourceMob.pyx"
include "mob/MobSlot.pyx"
include "mob/TimelineMobSlot.pyx"
include "mob/EventMobSlot.pyx"
include "mob/StaticMobSlot.pyx"

register_object(Mob)
register_object(MasterMob)
register_object(CompositionMob)
register_object(SourceMob)
register_object(MobSlot)
register_object(TimelineMobSlot)
register_object(EventMobSlot)
register_object(StaticMobSlot)
