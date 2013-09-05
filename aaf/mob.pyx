cimport lib
from base cimport AAFObject, AAFBase, AUID

from libcpp.vector cimport vector
from libcpp.string cimport string
from cpython cimport bool

from .util cimport error_check, query_interface, register_object, fraction_to_aafRational, MobID
from .iterator cimport MobSlotIter
from .component cimport Segment
from .essence cimport EssenceDescriptor, Locator, EssenceAccess
from .component cimport Segment
from .define cimport DataDef, CodecDefMap, ContainerDefMap

from wstring cimport wstring, wideToString, toWideString

from fractions import Fraction

cdef class Mob(AAFObject):
    def __init__(self, AAFBase obj=None):
        super(Mob, self).__init__(obj)
        self.iid = lib.IID_IAAFMob
        self.auid = lib.AUID_AAFMob
        self.ptr = NULL

        if not obj:
            return

        query_interface(obj.get_ptr(), <lib.IUnknown**>&self.ptr, lib.IID_IAAFMob)

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
            
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def slots(self):
        cdef MobSlotIter slot_iter = MobSlotIter()
        error_check(self.ptr.GetSlots(&slot_iter.ptr))    
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
        slot.slotID = index
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
        
        cdef TimelineMobSlot timeline = TimelineMobSlot()
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
        return TimelineMobSlot(timeline)
            
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
            
            
cdef class MasterMob(Mob):
    def __init__(self, AAFBase obj=None):
        super(MasterMob, self).__init__(obj)
        self.iid = lib.IID_IAAFMasterMob2
        self.auid = lib.AUID_AAFMasterMob
        self.mastermob_ptr = NULL
        self.mastermob2_ptr = NULL
        if not obj:
            return

        query_interface(obj.get_ptr(), <lib.IUnknown**>&self.mastermob_ptr, lib.IID_IAAFMasterMob)
        query_interface(obj.get_ptr(), <lib.IUnknown**>&self.mastermob2_ptr, lib.IID_IAAFMasterMob2)

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.mastermob_ptr
    
    def initialize(self, bytes name):
        error_check(self.mastermob_ptr.Initialize())
        if name:
            self.name = name
    
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
        
        print edit_rate_t,sample_rate_t,codec,container

        cdef Locator loc
        if locator:
            loc = locator
        else:
            loc = Locator()
        
        cdef EssenceAccess access = EssenceAccess()
        
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
        return access
        
    def __dealloc__(self):
        if self.mastermob_ptr:
            self.mastermob_ptr.Release()
        if self.mastermob2_ptr:
            self.mastermob2_ptr.Release()

cdef class CompositionMob(Mob):
    def __init__(self, AAFBase obj=None):
        super(CompositionMob, self).__init__(obj)
        self.iid = lib.IID_IAAFCompositionMob2
        self.auid = lib.AUID_AAFCompositionMob
        self.compositionmob_ptr = NULL
        self.compositionmob2_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown**>&self.compositionmob_ptr, lib.IID_IAAFCompositionMob)
        query_interface(obj.get_ptr(), <lib.IUnknown**>&self.compositionmob2_ptr, lib.IID_IAAFCompositionMob2)

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.compositionmob_ptr
    
    def initialize(self, bytes name):
        cdef wstring w_name = toWideString(name)
        
        error_check(self.compositionmob_ptr.Initialize(w_name.c_str()))
            
    def __dealloc__(self):
        if self.compositionmob_ptr:
            self.compositionmob_ptr.Release()
        if self.compositionmob2_ptr:
            self.compositionmob2_ptr.Release()
        
            
cdef class SourceMob(Mob):
    def __init__(self, AAFBase obj=None):
        super(SourceMob, self).__init__(obj)
        self.iid = lib.IID_IAAFSourceMob
        self.auid = lib.AUID_AAFSourceMob
        self.src_ptr = NULL

        if not obj:
            return

        query_interface(obj.get_ptr(), <lib.IUnknown**>&self.src_ptr, self.iid)

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.src_ptr
            
    def __dealloc__(self):
        if self.src_ptr:
            self.src_ptr.Release()
    
    def initialize(self):
        error_check(self.src_ptr.Initialize())
    
    property essence_descriptor:
        def __get__(self):
            cdef EssenceDescriptor descriptor = EssenceDescriptor()
            error_check(self.src_ptr.GetEssenceDescriptor(&descriptor.essence_ptr))
            return EssenceDescriptor(descriptor).resolve()
        
        def __set__(self, EssenceDescriptor descriptor):
            error_check(self.src_ptr.SetEssenceDescriptor(descriptor.essence_ptr))

cdef class MobSlot(AAFObject):
    def __init__(self, AAFBase obj = None):
        super(MobSlot, self).__init__(obj)
        self.iid = lib.IID_IAAFMobSlot
        self.auid = lib.AUID_AAFMobSlot
        self.slot_ptr = NULL
        if not obj:
            return
        query_interface(obj.get_ptr(), <lib.IUnknown**>&self.slot_ptr, self.iid)
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.slot_ptr
            
    def __dealloc__(self):
        if self.slot_ptr:
            self.slot_ptr.Release()
            
    def datadef(self):
        cdef DataDef data_def = DataDef()
        error_check(self.slot_ptr.GetDataDef(&data_def.ptr))
        return DataDef(data_def)
    
    property segment:
        def __get__(self):
            cdef Segment seg = Segment()
            error_check(self.slot_ptr.GetSegment(&seg.seg_ptr))
            return Segment(seg).resolve()
        
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
    def __init__(self, AAFBase obj = None):
        super(TimelineMobSlot, self).__init__(obj)
        self.iid = lib.IID_IAAFTimelineMobSlot
        self.auid = lib.AUID_AAFTimelineMobSlot
        self.ptr = NULL
        if not obj:
            return
        query_interface(obj.get_ptr(), <lib.IUnknown**>&self.ptr, self.iid)
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
            
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
            return Fraction(rate.numerator, rate.denominator)
        def __set__(self,value):
            cdef lib.aafRational_t rate
            fraction_to_aafRational(value,rate)
            error_check(self.ptr.SetEditRate(rate))
            
cdef class EventMobSlot(MobSlot):
    def __init__(self, AAFBase obj = None):
        super(EventMobSlot, self).__init__(obj)
        self.iid = lib.IID_IAAFEventMobSlot
        self.auid = lib.AUID_AAFEventMobSlot
        self.ptr = NULL
        if not obj:
            return
        query_interface(obj.get_ptr(), <lib.IUnknown**>&self.ptr, self.iid)
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
            
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