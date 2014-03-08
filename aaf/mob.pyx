cimport lib
from base cimport AAFObject, AAFBase

from libcpp.vector cimport vector
from libcpp.string cimport string
from cpython cimport bool

from libc.stdio cimport FILE, fopen, fclose, fread

from .util cimport error_check, query_interface, register_object, fraction_to_aafRational, SourceRef, Timecode, AUID, MobID
from .iterator cimport MobSlotIter, TaggedValueIter
from .component cimport Segment
from .essence cimport EssenceDescriptor, Locator, EssenceAccess
from .component cimport Segment
from .define cimport DataDef, CodecDefMap, ContainerDefMap, PullDownKindMap, PulldownDirMap
from .property cimport TaggedValue

from wstring cimport wstring, wideToString, toWideString

from struct import unpack

from .fraction_util import AAFFraction

cdef class Mob(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFMob
        self.auid = lib.AUID_AAFMob
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.ptr, lib.IID_IAAFMob)
            
        AAFObject.query_interface(self, obj)
            
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def slots(self):
        cdef MobSlotIter slot_iter = MobSlotIter.__new__(MobSlotIter)
        error_check(self.ptr.GetSlots(&slot_iter.ptr)) 
        slot_iter.root = self.root   
        return slot_iter
    
    def slot_at(self, lib.aafSlotID_t slotID):
        for slot in self.slots():
            if slot.slotID == slotID:
                return slot
        raise IndexError("Invalid slot number: %d" % slotID)
    
    def insert_slot(self, lib.aafUInt32 index, MobSlot slot):
        """
        Inserts the given slot into this mob at the given index.  All
        existing slots at the given and higher index will be moved up one
        index to accommodate.
        """
        error_check(self.ptr.InsertSlotAt(index, slot.slot_ptr))
        
    def create_clip(self, slotID=None, length=None, start_time=None):

        d = self.dictionary()
        
        if slotID is None:
            slotID = list(self.slots())[0].slotID
            
        source_slot = self.slot_at(slotID)
        
        if length is None:
            length = source_slot.segment.length
        
        if start_time is None:
            start_time = source_slot.origin
            
        return d.create.SourceClip(self, slotID, length, start_time)
        
    def add_timeline_slot(self, edit_rate, Segment seg, lib.aafSlotID_t slotID = 0, 
                            bytes slot_name = None, lib.aafPosition_t origin = 0):
        
        if not slot_name:
            slot_name = b'timeline slot %d' % slotID
        
        cdef TimelineMobSlot timeline = TimelineMobSlot.__new__(TimelineMobSlot)
        
        cdef lib.aafRational_t edit_rate_t
        
        
        fraction_to_aafRational(edit_rate, edit_rate_t)
        
        cdef wstring w_slot_name = toWideString(slot_name)
        
        error_check(self.ptr.AppendNewTimelineSlot(edit_rate_t,
                                                  seg.seg_ptr,
                                                  slotID,
                                                  w_slot_name.c_str(),
                                                  origin,
                                                  &timeline.ptr
                                                  ))
        timeline.query_interface()
        timeline.root = self.root
        return timeline
    
    def append_comment(self, bytes name, bytes value):
        cdef wstring w_name = toWideString(name)
        cdef wstring w_value = toWideString(value)
        
        error_check(self.ptr.AppendComment(<lib.aafCharacter *> w_name.c_str(), w_value.c_str()))
    
    def iter_comments(self):
        cdef TaggedValueIter tags = TaggedValueIter.__new__(TaggedValueIter)
        tags.root = self.root
        hr = self.ptr.GetComments(&tags.ptr)
        if hr == lib.AAFRESULT_PROP_NOT_PRESENT:
            return []
        else:
            error_check(hr)
        
        return tags
    def remove_comment(self, bytes name):
        
        cdef TaggedValue tag
        
        for tag in self.iter_comments():
            if tag.name == name:
                error_check(self.ptr.RemoveComment(tag.ptr))
                return
        raise KeyError("No comment with name: %s" % str(name))
    
    def __richcmp__(x, y, int op):
        if op == 2:
            
            if isinstance(x, Mob):
                x = x.mobID
            
            if isinstance(y, Mob):
                y = y.mobID

            if str(x) == str(y):
                return True
            return False
        raise NotImplemented("richcmp %d not not Implemented" % op)
        
    def __repr__(self):
        name = self.name
        if name:
            return '<%s.%s %s %s at 0x%x>' % (
                self.__class__.__module__,
                self.__class__.__name__,
                name, str(self.mobID), 
                id(self),
                )
        else:
            return '<%s.%s %s at 0x%x>' % (
                self.__class__.__module__,
                self.__class__.__name__,
                str(self.mobID), 
                id(self),
                )
    
    property name:
        def __get__(self):
            for p in self.properties():
                if p.name == 'Name':
                    name = p.value
                    if name:
                        return name

            return None
        
        def __set__(self, bytes value):
            cdef wstring name = toWideString(value)
            error_check(self.ptr.SetName(name.c_str()))
            
    property nb_slots:
        def __get__(self):
            cdef lib.aafNumSlots_t nb_slots
            error_check(self.ptr.CountSlots(&nb_slots))
            return nb_slots
    property mobID:
        """
        The unique Mob ID associated with this mob. Get Returns MobID Object
        """
        def __get__(self):
            cdef lib.aafMobID_t mobID
            error_check(self.ptr.GetMobID(&mobID))
            cdef MobID mobID_obj = MobID()
            
            mobID_obj.mobID = mobID
            return mobID_obj
        
        def __set__(self, value):
            cdef MobID mobID_obj = MobID(value)
            error_check(self.ptr.SetMobID(mobID_obj.get_aafMobID_t()))
            
            
cdef class MasterMob(Mob):
    def __cinit__(self):
        self.iid = lib.IID_IAAFMasterMob2
        self.auid = lib.AUID_AAFMasterMob
        self.mastermob_ptr = NULL
        self.mastermob2_ptr = NULL
        self.mastermob3_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.mastermob_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.mastermob_ptr, lib.IID_IAAFMasterMob)
        
        if not self.mastermob2_ptr:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.mastermob2_ptr, lib.IID_IAAFMasterMob2)
        
        if not self.mastermob3_ptr:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.mastermob3_ptr, lib.IID_IAAFMasterMob3)
            
        Mob.query_interface(self, obj)
    
    def initialize(self, bytes name = None):
        error_check(self.mastermob_ptr.Initialize())
        if name:
            self.name = name
            
    def new_phys_source_ref(self, edit_rate, lib.aafSlotID_t  slotID, media_kind, SourceRef ref, lib.aafLength_t  srcRefLength):
        cdef lib.aafRational_t edit_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)
        
        error_check(self.mastermob_ptr.NewPhysSourceRef(edit_rate_t,
                                                  slotID,
                                                  data_def.ptr,
                                                  ref.get_aafSourceRef_t(),
                                                  srcRefLength)) 
            
    def open_essence(self, lib.aafSlotID_t  slotID):
        
        slot = self.slot_at(slotID)
        
        cdef EssenceAccess access = EssenceAccess.__new__(EssenceAccess)
        
        error_check(self.mastermob_ptr.OpenEssence(slotID,
                                                   NULL,
                                                   lib.kAAFMediaOpenReadOnly,
                                                   lib.kAAFCompressionDisable,
                                                   &access.ptr))
        access.query_interface()
        access.datadef = slot.datadef()
        access.root = self.root
        return access
    
    def create_essence(self,lib.aafSlotID_t slot_index, 
                            bytes media_kind,
                            bytes codec_name,
                            edit_rate, sample_rate, 
                            bool compress=False,
                            Locator locator=None, 
                            bytes fileformat = b"aaf"):
        
        cdef DataDef media_datadef        
        media_datadef = self.dictionary().lookup_datadef(media_kind)

        cdef lib.aafRational_t edit_rate_t
        cdef lib.aafRational_t sample_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)
        fraction_to_aafRational(sample_rate, sample_rate_t)
        
        cdef AUID codec = CodecDefMap[codec_name.lower()]
        cdef AUID container = ContainerDefMap[fileformat.lower()]
        
        cdef Locator loc
        if locator:
            loc = locator
        else:
            loc = Locator.__new__(Locator)
        
        cdef EssenceAccess access = EssenceAccess.__new__(EssenceAccess)
        
        cdef lib.aafCompressEnable_t enable = lib.kAAFCompressionEnable
        if not compress:
            enable = lib.kAAFCompressionDisable

        error_check(self.mastermob_ptr.CreateEssence( slot_index,
                                                      media_datadef.ptr,
                                                      codec.get_auid(),
                                                      edit_rate_t,
                                                      sample_rate_t,
                                                      enable,
                                                      loc.loc_ptr,
                                                      container.get_auid(),
                                                      &access.ptr
                                                      ))
        access.query_interface()
        access.datadef = media_datadef
        access.root = self.root
        return access
    
    def import_video_essence(self, bytes path, object frame_rate):
        """
        Import raw dnxhd video stream from file.
        """
        
        f = open(path, 'rb')
        dnx_header = f.read(640)
        f.close()

        if len(dnx_header) != 640:
            raise ValueError("Invalid DNxHD file: header to Short")

        header_prefix = (0x00, 0x00, 0x02, 0x80, 0x01)

        if header_prefix != unpack(">BBBBB", dnx_header[:5]):
            raise ValueError("Invalid DNxHD file: header magick number wrong")

        width, height = unpack(">24xhh", dnx_header[:28])
        codec_id = unpack(">40xi", dnx_header[:44])[0]
        
        slot_index = 0
        
        for slot in self.slots():
            slot_index = max(slot_index, slot.slotID)
            
        slot_index += 1
        
        cdef EssenceAccess essence
        
        essence = self.create_essence(slot_index,
                                     'picture',
                                     "DNxHD",
                                     frame_rate,
                                     frame_rate,
                                     compress = False)
        
        essence.codec_flavour = "Flavour_VC3_%d" % codec_id
        
        video = open(path)
        readsize = essence.max_sample_size
        
        
        cdef FILE* cfile
    
        cfile = fopen(path, 'rb')
        if cfile == NULL:
            raise ValueError()
        
        cdef unsigned char data[1024]
        
        cdef size_t buffer_size = 1024
        cdef size_t result =0
        
        cdef lib.aafUInt32 samples_written =0
        cdef lib.aafUInt32 bytes_written =0
        
        try:
            while True:
                result = fread(data, 1, buffer_size, cfile)
                if result == 0:
                    break
                
                error_check(essence.ptr.WriteSamples(1,
                                                     result,
                                                     data,
                                                     &samples_written,
                                                     &bytes_written))
            essence.complete_write()
        finally:
            fclose(cfile)

    def import_audio_essence(self, bytes path, lib.aafUInt32 channels, object sample_rate):
        """
        Import raw PCM audio stream from file.
        """
        
        slot_index = 0
        for slot in self.slots():
            slot_index = max(slot_index, slot.slotID)
        slot_index += 1

        audio_essences = []
        
        cdef EssenceAccess essence
    
        # Add essences for each audio channel
        for i in xrange(channels):
            essence = self.create_essence(slot_index+i,
                                         'sound',
                                         "PCM",
                                         sample_rate,
                                         sample_rate,
                                         compress = False)
            
            essence.codec_flavour = "Flavour_None"
            format = essence.get_emptyfileformat()
            format['AudioSampleBits'] = 16
            format['NumChannels'] = 1
            essence.set_fileformat(format)
            audio_essences.append(essence)
            
        #audio = open(path)
        
        # each sample is 2 bytes
        readsize = 2
        
        cdef FILE* cfile
        
        cfile = fopen(path, 'rb')
        if cfile == NULL:
            raise ValueError()
        
        cdef unsigned char data[2]
        cdef size_t result =0
        
        cdef lib.aafUInt32 samples_written =0
        cdef lib.aafUInt32 bytes_written =0
        
        try:
            while True:
                for essence in audio_essences:
                    result = fread(data, 1,2, cfile)
                    if result != 2:
                        break
                    
                    error_check(essence.ptr.WriteSamples(1,
                                                     2,
                                                     data,
                                                     &samples_written,
                                                     &bytes_written))
                if result != 2:
                    break
                
            for essence in audio_essences:
                essence.complete_write()
        finally:            
            fclose(cfile)

    
    def add_master_slot(self, media_kind, lib.aafSlotID_t source_slotID, SourceMob source_mob, 
                        lib.aafSlotID_t master_slotID, bytes slot_name=None):
        """
        Add a slot that references the specified a slot in the specified Source Mob.
        """
        cdef DataDef media_datadef        
        media_datadef = self.dictionary().lookup_datadef(media_kind)
        
        if not slot_name:
            slot_name = b""
        
        cdef wstring w_slot_name = toWideString(slot_name)

        error_check(self.mastermob_ptr.AddMasterSlot(media_datadef.ptr,
                                                     source_slotID,
                                                     source_mob.src_ptr,
                                                     master_slotID,
                                                     w_slot_name.c_str()))
        for slot in self.slots():
            if slot.slotID == master_slotID:
                return slot
        
        raise RuntimeError("could not find added master slot")
        
    def add_master_slot_with_sequence(self, media_kind, lib.aafSlotID_t source_slotID, SourceMob source_mob, 
                                      lib.aafSlotID_t master_slotID, bytes slot_name=None):
        
        cdef DataDef media_datadef        
        media_datadef = self.dictionary().lookup_datadef(media_kind)
        
        if not slot_name:
            slot_name = b""
        
        cdef wstring w_slot_name = toWideString(slot_name)
        
        error_check(self.mastermob3_ptr.AddMasterSlotWithSequence(media_datadef.ptr,
                                                     source_slotID,
                                                     source_mob.src_ptr,
                                                     master_slotID,
                                                     w_slot_name.c_str()))
        for slot in self.slots():
            if slot.slotID == master_slotID:
                return slot
        
        raise RuntimeError("could not find added master slot")
        
    def __dealloc__(self):
        if self.mastermob_ptr:
            self.mastermob_ptr.Release()
        if self.mastermob2_ptr:
            self.mastermob2_ptr.Release()

cdef class CompositionMob(Mob):
    def __cinit__(self):
        self.iid = lib.IID_IAAFCompositionMob2
        self.auid = lib.AUID_AAFCompositionMob
        self.compositionmob_ptr = NULL
        self.compositionmob2_ptr = NULL
        
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.compositionmob_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.compositionmob_ptr, lib.IID_IAAFCompositionMob)
        
        if not self.compositionmob2_ptr:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.compositionmob2_ptr, lib.IID_IAAFCompositionMob2)
            
        Mob.query_interface(self, obj)
    
    def initialize(self, bytes name = None):
        if not name:
            name = b"composition mob"
        
        cdef wstring w_name = toWideString(name)
        
        error_check(self.compositionmob_ptr.Initialize(w_name.c_str()))
            
    def __dealloc__(self):
        if self.compositionmob_ptr:
            self.compositionmob_ptr.Release()
        if self.compositionmob2_ptr:
            self.compositionmob2_ptr.Release()
        
            
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
    
    def initialize(self):
        error_check(self.src_ptr.Initialize())
        
    def add_nil_ref(self, lib.aafSlotID_t slotID, lib.aafLength_t length, media_kind, edit_rate):
        cdef lib.aafRational_t edit_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)
        
        error_check(self.src_ptr.AddNilReference(slotID, length, data_def.ptr, edit_rate_t))
        
    def add_pulldown(self, 
                     edit_rate, 
                     lib.aafSlotID_t slotID, media_kind, 
                     SourceRef source_ref,
                     lib.aafLength_t src_ref_length,
                     bytes pulldown_kind = b"TwentyFourToSixtyPD",
                     lib.aafPhaseFrame_t phase_frame = 0,
                     bytes direction = b"TapeToFilmSpeed",
                     bytes add_type = b"append"):
        
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
        
    def append_timecode_slot(self, edit_rate, lib.aafSlotID_t  slotID, Timecode startTC, lib.aafFrameLength_t frame_length):
        
        cdef lib.aafRational_t edit_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)
        
        error_check(self.src_ptr.AppendTimecodeSlot(edit_rate_t,
                                                    slotID,
                                                    startTC.get_timecode_t(),
                                                    frame_length
                                                    ))   
    
    def new_phys_source_ref(self, edit_rate, lib.aafSlotID_t  slotID, media_kind, SourceRef ref, lib.aafLength_t  srcRefLength):
        cdef lib.aafRational_t edit_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)
        
        error_check(self.src_ptr.NewPhysSourceRef(edit_rate_t,
                                                  slotID,
                                                  data_def.ptr,
                                                  ref.get_aafSourceRef_t(),
                                                  srcRefLength))
    def append_phys_source_ref(self, edit_rate, lib.aafSlotID_t  slotID, media_kind, SourceRef ref, lib.aafLength_t  srcRefLength):
        cdef lib.aafRational_t edit_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)
        
        error_check(self.src_ptr.AppendPhysSourceRef(edit_rate_t,
                                                     slotID,
                                                     data_def.ptr,
                                                     ref.get_aafSourceRef_t(),
                                                     srcRefLength))
                                            
    property essence_descriptor:
        def __get__(self):
            cdef EssenceDescriptor descriptor = EssenceDescriptor.__new__(EssenceDescriptor)
            error_check(self.src_ptr.GetEssenceDescriptor(&descriptor.essence_ptr))
            descriptor.query_interface()
            descriptor.root = self.root
            return descriptor.resolve()
        
        def __set__(self, EssenceDescriptor descriptor):
            error_check(self.src_ptr.SetEssenceDescriptor(descriptor.essence_ptr))

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
        
        def __set__(self, bytes value):
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
        
    property slotID:
        def __get__(self):
            cdef lib.aafSlotID_t slotID
            error_check(self.slot_ptr.GetSlotID(&slotID))
            return slotID
        def __set__(self, lib.aafSlotID_t value):
            error_check(self.slot_ptr.SetSlotID(value))
    
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
        
    
cdef class TimelineMobSlot(MobSlot):
    def __cinit__(self, AAFBase obj = None):
        self.iid = lib.IID_IAAFTimelineMobSlot
        self.auid = lib.AUID_AAFTimelineMobSlot
        self.ptr = NULL
        
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.ptr, lib.IID_IAAFTimelineMobSlot)

        MobSlot.query_interface(self, obj)
            
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def initialize(self):
        error_check(self.ptr.Initialize())
    
    property origin:
        def __get__(self):
            cdef lib.aafPosition_t origin
            error_check(self.ptr.GetOrigin(&origin))
            return origin
        def __set__(self, lib.aafPosition_t value):
            error_check(self.ptr.SetOrigin(value))
    property editrate:
        def __get__(self):
            cdef lib.aafRational_t rate
            error_check(self.ptr.GetEditRate(&rate))
            return AAFFraction(rate.numerator, rate.denominator)
        def __set__(self,value):
            cdef lib.aafRational_t rate
            fraction_to_aafRational(value,rate)
            error_check(self.ptr.SetEditRate(rate))
            
cdef class EventMobSlot(MobSlot):
    def __cinit__(self, AAFBase obj = None):
        self.iid = lib.IID_IAAFEventMobSlot
        self.auid = lib.AUID_AAFEventMobSlot
        self.ptr = NULL
        
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.ptr, lib.IID_IAAFEventMobSlot)

        MobSlot.query_interface(self, obj)
            
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
            
register_object(Mob)           
register_object(MasterMob)
register_object(CompositionMob)
register_object(SourceMob)
register_object(MobSlot)
register_object(TimelineMobSlot)
register_object(EventMobSlot)
