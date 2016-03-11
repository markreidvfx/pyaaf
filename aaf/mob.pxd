cimport lib

from base cimport AAFObject

cdef class Mob(AAFObject):
    cdef lib.IAAFMob *ptr
    cdef lib.IAAFMob2 *mob2_ptr

cdef class MasterMob(Mob):
    cdef lib.IAAFMasterMob *mastermob_ptr
    cdef lib.IAAFMasterMob2 *mastermob2_ptr
    cdef lib.IAAFMasterMob3 *mastermob3_ptr

cdef class CompositionMob(Mob):
    cdef lib.IAAFCompositionMob *compositionmob_ptr
    cdef lib.IAAFCompositionMob2 *compositionmob2_ptr

cdef class SourceMob(Mob):
    cdef lib.IAAFSourceMob *src_ptr

cdef class MobSlot(AAFObject):
    cdef lib.IAAFMobSlot *slot_ptr

cdef class TimelineMobSlot(MobSlot):
    cdef lib.IAAFTimelineMobSlot *ptr
    cdef lib.IAAFTimelineMobSlot2 *ptr2

cdef class EventMobSlot(MobSlot):
    cdef lib.IAAFEventMobSlot *ptr

cdef class StaticMobSlot(MobSlot):
    cdef lib.IAAFStaticMobSlot *ptr
