cdef class SourceRef(object):
    def __init__(self, source_id, lib.aafSlotID_t source_slot_id, lib.aafPosition_t start_time=0):
        self.source_id= source_id
        self.source_slot_id = source_slot_id
        self.start_time = start_time
        
    cdef lib.aafSourceRef_t get_aafSourceRef_t(self):
        return self.source_ref
    
    def __repr__(self):
        return '<%s.%s of %s source_slot_id:%si start_time:%i at 0x%x>' % (
            self.__class__.__module__,
            self.__class__.__name__,
            self.source_id, self.source_slot_id, self.start_time,
            id(self))
    
    property source_id:
        def __get__(self):
            cdef MobID mob_id = MobID()
            mob_id.mobID = self.source_ref.sourceID
            return mob_id
        def __set__(self, value):
            cdef MobID mob_id = MobID(value)
            self.source_ref.sourceID = mob_id.get_aafMobID_t()
        
    property source_slot_id:
        def __get__(self):
            return self.source_ref.sourceSlotID
        def __set__(self, lib.aafSlotID_t value):
            self.source_ref.sourceSlotID = value
    
    property start_time:
        def __get__(self):
            return self.source_ref.startTime
        def __set__(self, lib.aafPosition_t value):
            self.source_ref.startTime = value