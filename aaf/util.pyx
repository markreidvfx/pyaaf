
cimport lib

from wstring cimport wstring, toWideString,wideToString
from libcpp.string cimport string
from libc.stddef cimport wchar_t

from .fraction_util import AAFFraction

import uuid

HRESULTS = lib.get_hrmap()


# This function is defined in the define module
# and set via set_resolver_func to avoid import base into this module
cdef object RESOLVE_OBJECT_FUNC = None

cdef dict OBJECT_MAP = {}

cdef object error_check(int ret):
    if not lib.SUCCEEDED(ret):
        message = "Unknown Error"
        if HRESULTS.has_key(ret):
            message =  HRESULTS[ret]
    
        raise Exception("failed with [%d]: %s" % (ret, message))
    
    return ret

cdef object query_interface(lib.IUnknown **src, lib.IUnknown **dst, lib.GUID guid):
    if not src[0]:
        raise Exception("src cannot be a null pointer")
    error_check(src[0].QueryInterface(guid, <void**> dst))

cdef lib.aafCharacter* aafChar(char* s):
    
    cdef wstring wstr = toWideString(s)
    
    return <lib.aafCharacter *> wstr.c_str()

cdef char* toChar(lib.aafCharacter* s):
    
    cdef wstring wstr = wstring(<wchar_t*>s)
    
    cdef string mbs = wideToString(wstr)
    
    return <char *> mbs.c_str()

cdef object register_object(object obj):
    global OBJECT_MAP
    OBJECT_MAP[obj.__name__] = obj

cdef object lookup_object(bytes name):
    global OBJECT_MAP
    rename = name
    for n,r in (("",""), ("Definition", "Def")):
        rename = rename.replace(n,r)
        if OBJECT_MAP.has_key(rename):
            return OBJECT_MAP[rename]
    raise KeyError("No object named %s" % name)

cdef object set_resolve_object_func(object obj):
    global RESOLVE_OBJECT_FUNC
    RESOLVE_OBJECT_FUNC = obj

cdef object resolve_object(object obj):
    return RESOLVE_OBJECT_FUNC(obj)

cdef object fraction_to_aafRational(object obj, lib.aafRational_t& r):
    
    f = AAFFraction(obj)
    r.numerator = f.numerator
    r.denominator = f.denominator
    
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
        
cdef class Timecode(object):
    
    def __init__(self, lib.aafFrameOffset_t start_frame = 0, bytes drop = b"NonDrop", lib.aafUInt16 fps = 25):
        
        self.start_frame = start_frame
        self.drop = drop
        self.fps = fps
    
    def __repr__(self):
        return '<%s.%s of start_frame:%i drop:%s fps:%i at 0x%x>' % (
            self.__class__.__module__,
            self.__class__.__name__,
            self.start_frame, self.drop, self.fps,
            id(self))
    cdef lib.aafTimecode_t get_timecode_t(self):
        return self.timecode
    
    property start_frame:
        def __get__(self):
            return self.timecode.startFrame
        def __set__(self, lib.aafFrameOffset_t value):
            self.timecode.startFrame = value
            
    property drop:
        def __get__(self):
            if self.timecode.drop == lib.kAAFTcNonDrop:
                return "nondrop"
            else:
                return 'drop'
            
        def __set__(self, bytes value):
            if value.lower() == "nondrop":
                self.timecode.drop = lib.kAAFTcNonDrop
            elif value.lower() == 'drop':
                self.timecode.drop = lib.kAAFTcNonDrop
            else:
                raise ValueError('invalid drop type: %s. must be "drop" or "nondrop"' % value)
    property fps:
        def __get__(self):
            return self.timecode.fps
        def __set__(self, lib.aafUInt16 value):
            self.timecode.fps = value
            

cdef class AUID(object):
    def __init__(self, auid = None):
    
        if not auid:
            return
        
        auid = uuid.UUID(str(auid))
        items = auid.urn.replace('urn:uuid:', '').split('-')

        self.auid.Data1 = int(items[0], 16)
        self.auid.Data2 = int(items[1], 16)
        self.auid.Data3 = int(items[2], 16)
        
        self.auid.Data4[0] = int(items[3][:2], 16)
        self.auid.Data4[1] = int(items[3][2:4], 16)
        
        self.auid.Data4[2] = int(items[4][:2], 16)
        self.auid.Data4[3] = int(items[4][2:4], 16)
        self.auid.Data4[4] = int(items[4][4:6], 16)
        self.auid.Data4[5] = int(items[4][6:8], 16)
        self.auid.Data4[6] = int(items[4][8:10], 16)
        self.auid.Data4[7] = int(items[4][10:12], 16)
        
    cdef lib.aafUID_t get_auid(self):
        return self.auid
    cdef lib.GUID get_iid(self):
        cdef lib.GUID iid
        iid.Data1 = self.auid.Data1
        iid.Data2 = self.auid.Data2
        iid.Data3 = self.auid.Data3
        
        for i in xrange(8):
            iid.Data4[i] = self.auid.Data4[i]
        
        return iid
    
    cdef void from_auid(self, lib.aafUID_t auid):
        self.auid = auid
        
    cdef void from_iid(self, lib.GUID iid):
        self.auid.Data1 = iid.Data1
        self.auid.Data2 = iid.Data2
        self.auid.Data3 = iid.Data3
        for i in xrange(8):
            self.auid.Data4[i] = iid.Data4[i]
        
    def to_UUID(self):
        return uuid.UUID(str(self))
        
    def __richcmp__(x, y, int op):
        if op == 2:
            if isinstance(x, uuid.UUID):
                x = x.urn
                
            if isinstance(y, uuid.UUID):
                y = y.urn
            
            if str(x) == str(y):
                return True
            return False
        raise NotImplemented("richcmp %d not not Implemented" % op)
        
    def __repr__(self):
        return '<%s.%s of %s at 0x%x>' % (
            self.__class__.__module__,
            self.__class__.__name__,
            str(self),
            id(self),
        )
        
    def __str__(self):
        return "urn:uuid:%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x" % (
        self.auid.Data1, self.auid.Data2, self.auid.Data3,
        self.auid.Data4[0], self.auid.Data4[1], self.auid.Data4[2], self.auid.Data4[3],
        self.auid.Data4[4], self.auid.Data4[5], self.auid.Data4[6], self.auid.Data4[7]
        )
    
cdef class MobID(object):

    def __init__(self, mobID = None):
        if not mobID:
            return

        s = str(mobID).replace("urn:smpte:umid:" ,"")
        
        items = s.split(".")
        
        if len(items) != 8:
            raise ValueError("Invalid MobID")

        
        self.mobID.SMPTELabel[0] = int(items[0][:2], 16)
        self.mobID.SMPTELabel[1] = int(items[0][2:4], 16)
        self.mobID.SMPTELabel[2] = int(items[0][4:6], 16)
        self.mobID.SMPTELabel[3] = int(items[0][6:8], 16)
        
        self.mobID.SMPTELabel[4] = int(items[1][:2], 16)
        self.mobID.SMPTELabel[5] = int(items[1][2:4], 16)
        self.mobID.SMPTELabel[6] = int(items[1][4:6], 16)
        self.mobID.SMPTELabel[7] = int(items[1][6:8], 16)
        
        self.mobID.SMPTELabel[8] = int(items[2][:2], 16)
        self.mobID.SMPTELabel[9] = int(items[2][2:4], 16)
        self.mobID.SMPTELabel[10] = int(items[2][4:6], 16)
        self.mobID.SMPTELabel[11] = int(items[2][6:8], 16)
        
        self.mobID.length = int(items[3][:2], 16)
        
        self.mobID.instanceHigh = int(items[3][2:4], 16)
        self.mobID.instanceMid = int(items[3][4:6], 16)
        self.mobID.instanceLow = int(items[3][6:8], 16)
        
        self.mobID.material.Data4[0] = int(items[4][:2], 16)
        self.mobID.material.Data4[1] = int(items[4][2:4], 16)
        self.mobID.material.Data4[2] = int(items[4][4:6], 16)
        self.mobID.material.Data4[3] = int(items[4][6:8], 16)
        
        self.mobID.material.Data4[4] = int(items[5][:2], 16)
        self.mobID.material.Data4[5] = int(items[5][2:4], 16)
        self.mobID.material.Data4[6] = int(items[5][4:6], 16)
        self.mobID.material.Data4[7] = int(items[5][6:8], 16)
        
        self.mobID.material.Data1 = int(items[6], 16)
        
        self.mobID.material.Data2 = int(items[7][0:4], 16)
        self.mobID.material.Data3 = int(items[7][4:], 16)
        
    cdef lib.aafMobID_t get_aafMobID_t(self):
        return self.mobID
    
    def __richcmp__(x, y, int op):
        if op == 2:
            if str(x) == str(y):
                return True
            return False
        raise NotImplemented("richcmp %d not not Implemented" % op)
        
    
    def __repr__(self):
        return '<%s.%s of %s at 0x%x>' % (
            self.__class__.__module__,
            self.__class__.__name__,
            str(self),
            id(self),
        )

    def __str__(self):
        
        f = b"urn:smpte:umid:%02x%02x%02x%02x.%02x%02x%02x%02x.%02x%02x%02x%02x." + \
             "%02x"  + \
             "%02x%02x%02x." + \
             "%02x%02x%02x%02x.%02x%02x%02x%02x.%08x.%04x%04x"
        mobID = self.mobID
        return f % (
             mobID.SMPTELabel[0], mobID.SMPTELabel[1], mobID.SMPTELabel[2],  mobID.SMPTELabel[3],
             mobID.SMPTELabel[4], mobID.SMPTELabel[5], mobID.SMPTELabel[6],  mobID.SMPTELabel[7],
             mobID.SMPTELabel[8], mobID.SMPTELabel[9], mobID.SMPTELabel[10], mobID.SMPTELabel[11],
             mobID.length,
             mobID.instanceHigh, mobID.instanceMid, mobID.instanceLow,
             mobID.material.Data4[0], mobID.material.Data4[1], mobID.material.Data4[2], mobID.material.Data4[3],
             mobID.material.Data4[4], mobID.material.Data4[5], mobID.material.Data4[6], mobID.material.Data4[7],
             mobID.material.Data1, mobID.material.Data2, mobID.material.Data3)
        
