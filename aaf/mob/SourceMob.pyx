
cdef class SourceMob(Mob):
    def __cinit__(self):
        self.iid = lib.IID_IAAFSourceMob
        self.auid = lib.AUID_AAFSourceMob
        self.src_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.src_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.src_ptr, lib.IID_IAAFSourceMob)

        Mob.query_interface(self, obj)

    def __dealloc__(self):
        if self.src_ptr:
            self.src_ptr.Release()

    def __init__(self, root, name = None):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        error_check(self.src_ptr.Initialize())
        if name:
            self.name = name

    def add_nil_ref(self, lib.aafSlotID_t slotID, lib.aafLength_t length, media_kind, edit_rate):
        """add_nil_ref(slotID, length, media_kind, edit_rate)
        """
        cdef lib.aafRational_t edit_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)

        error_check(self.src_ptr.AddNilReference(slotID, length, data_def.ptr, edit_rate_t))

        return self.slot_at(slotID)

    def add_pulldown(self,
                     edit_rate,
                     lib.aafSlotID_t slotID, media_kind,
                     SourceRef source_ref,
                     lib.aafLength_t src_ref_length,
                     pulldown_kind = "TwentyFourToSixtyPD",
                     lib.aafPhaseFrame_t phase_frame = 0,
                     direction = "TapeToFilmSpeed",
                     add_type = "append"):
        """add_pulldown(edit_rate, slotID, media_kind, source_ref, src_ref_length, pulldown_kind = "TwentyFourToSixtyPD", phase_frame = 0, direction = "TapeToFilmSpeed", add_type = b"append")
        """

        cdef lib.aafAppendOption_t addType
        if add_type.lower() == "append":
            addType = lib.kAAFAppend
        elif add_type.lower() == 'overwrite':
            addType= lib.kAAFForceOverwrite
        else:
            raise ValueError('invalid add_type: %s. must be "append" or "overwrite"' % add_type)

        cdef lib.aafRational_t edit_rate_t

        cdef lib.aafPulldownKind_t pulldown_kind_t = PullDownKindMap[pulldown_kind.lower()]
        cdef lib.aafPulldownDir_t direction_t = PulldownDirMap[direction.lower()]

        cdef lib.aafSourceRef_t ref = source_ref.get_aafSourceRef_t()

        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)

        fraction_to_aafRational(edit_rate, edit_rate_t)

        error_check(self.src_ptr.AddPulldownRef(addType,
                                                 edit_rate_t,
                                                 slotID,
                                                 data_def.ptr,
                                                 ref,
                                                 src_ref_length,
                                                 pulldown_kind_t,
                                                 phase_frame,
                                                 direction_t
                                                 ))

        return self.slot_at(slotID)

    def append_timecode_slot(self, edit_rate, lib.aafSlotID_t  slotID, Timecode startTC, lib.aafFrameLength_t frame_length):
        """append_timecode_slot(edit_rate, slotID, startTC, frame_length)
        """

        cdef lib.aafRational_t edit_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)

        error_check(self.src_ptr.AppendTimecodeSlot(edit_rate_t,
                                                    slotID,
                                                    startTC.get_timecode_t(),
                                                    frame_length
                                                    ))

        return self.slot_at(slotID)

    def new_phys_source_ref(self, edit_rate, lib.aafSlotID_t  slotID, media_kind, SourceRef ref, lib.aafLength_t  srcRefLength):
        """new_phys_source_ref(edit_rate, slotID, media_kind, ref, srcRefLength)
        """

        cdef lib.aafRational_t edit_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)

        error_check(self.src_ptr.NewPhysSourceRef(edit_rate_t,
                                                  slotID,
                                                  data_def.ptr,
                                                  ref.get_aafSourceRef_t(),
                                                  srcRefLength))
    def append_phys_source_ref(self, edit_rate, lib.aafSlotID_t  slotID, media_kind, SourceRef ref, lib.aafLength_t  srcRefLength):
        """append_phys_source_ref(edit_rate, slotID, media_kind, ref, srcRefLength)
        """

        cdef lib.aafRational_t edit_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)

        error_check(self.src_ptr.AppendPhysSourceRef(edit_rate_t,
                                                     slotID,
                                                     data_def.ptr,
                                                     ref.get_aafSourceRef_t(),
                                                     srcRefLength))

        return self.slot_at(slotID)

    property essence_descriptor:
        def __get__(self):
            cdef EssenceDescriptor descriptor = EssenceDescriptor.__new__(EssenceDescriptor)
            error_check(self.src_ptr.GetEssenceDescriptor(&descriptor.essence_ptr))
            descriptor.query_interface()
            descriptor.root = self.root
            return descriptor.resolve()

        def __set__(self, EssenceDescriptor descriptor):
            error_check(self.src_ptr.SetEssenceDescriptor(descriptor.essence_ptr))
