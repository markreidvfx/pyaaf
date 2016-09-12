
cdef class MobSlot(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFMobSlot
        self.auid = lib.AUID_AAFMobSlot
        self.slot_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.slot_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.slot_ptr, lib.IID_IAAFMobSlot)

        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.slot_ptr:
            self.slot_ptr.Release()

    def datadef(self):
        cdef DataDef data_def = DataDef.__new__(DataDef)
        error_check(self.slot_ptr.GetDataDef(&data_def.ptr))
        data_def.query_interface()
        data_def.root = self.root
        return data_def

    property name:
        def __get__(self):
            return self.get_value("SlotName", None)

        def __set__(self, value):
            self['SlotName'].value = value

    property segment:
        def __get__(self):
            cdef Segment seg = Segment.__new__(Segment)
            error_check(self.slot_ptr.GetSegment(&seg.seg_ptr))
            seg.query_interface()
            seg.root = self.root
            return seg.resolve()

        def __set__(self, Segment value):
            error_check(self.slot_ptr.SetSegment(value.seg_ptr))

    property media_kind:
        def __get__(self):
            return self.datadef().name

    property slot_id:
        def __get__(self):
            cdef lib.aafSlotID_t slotID
            error_check(self.slot_ptr.GetSlotID(&slotID))
            return slotID
        def __set__(self, lib.aafSlotID_t value):
            error_check(self.slot_ptr.SetSlotID(value))

    property slotID:
        def __get__(self):
            return self.slot_id
        def __set__(self, value):
            self.slot_id = value

    property physical_num:
        """
        Audio channel, audio 1 = left 2 = right (leave video as 0)
        """
        def __get__(self):
            cdef lib.aafUInt32 value
            error_check(self.slot_ptr.GetPhysicalNum(&value))
            return value
        def __set__(self, lib.aafUInt32 value):
            error_check(self.slot_ptr.SetPhysicalNum(value))
