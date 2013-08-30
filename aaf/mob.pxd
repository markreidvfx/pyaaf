cimport lib

from base cimport AAFObject

cdef class MobID(object):
    cdef lib.aafMobID_t mobID

cdef class Mob(AAFObject):
    cdef lib.IAAFMob *ptr
    
cdef class MasterMob(Mob):
    cdef lib.IAAFMasterMob *mastermob_ptr
    cdef lib.IAAFMasterMob2 *mastermob2_ptr
    
cdef class CompositionMob(Mob):
    cdef lib.IAAFCompositionMob *compositionmob_ptr
    cdef lib.IAAFCompositionMob2 *compositionmob2_ptr
    
cdef class SourceMob(Mob):
    cdef lib.IAAFSourceMob *src_ptr

cdef class MobSlot(AAFObject):
    cdef lib.IAAFMobSlot *slot_ptr
    
cdef class TimelineMobSlot(MobSlot):
    cdef lib.IAAFTimelineMobSlot *ptr

cdef class EventMobSlot(MobSlot):
    pass
    
cdef class StaticMobSlot(MobSlot):
    pass