cdef class SourceRef(object):

    def __cinit__(self):
        memset(&self.source_ref, 0 , sizeof(lib.aafSourceRef_t))

    def __init__(self, mob_id = None, slot_id = None, start_time = None):

        if mob_id is not None:
            self.mob_id= mob_id

        if slot_id is not None:
            self.slot_id = slot_id

        if start_time is not None:
            self.start_time = start_time

    cdef lib.aafSourceRef_t get_aafSourceRef_t(self):
        return self.source_ref

    def __repr__(self):
        return '<%s.%s of %s slot_id:%s start_time:%i at 0x%x>' % (
            self.__class__.__module__,
            self.__class__.__name__,
            self.mob_id, self.slot_id, self.start_time,
            id(self))

    property mob_id:
        def __get__(self):
            cdef MobID mob_id = MobID()
            mob_id.mobID = self.source_ref.sourceID
            return mob_id
        def __set__(self, value):
            cdef MobID mob_id = MobID(value)
            self.source_ref.sourceID = mob_id.get_aafMobID_t()

    property slot_id:
        def __get__(self):
            return self.source_ref.sourceSlotID
        def __set__(self, lib.aafSlotID_t value):
            self.source_ref.sourceSlotID = value

    property start_time:
        def __get__(self):
            return self.source_ref.startTime
        def __set__(self, lib.aafPosition_t value):
            self.source_ref.startTime = value
