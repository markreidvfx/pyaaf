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
    
    @staticmethod
    def from_list(mobid_list):
        f = b"urn:smpte:umid:%02x%02x%02x%02x.%02x%02x%02x%02x.%02x%02x%02x%02x." + \
             "%02x"  + \
             "%02x%02x%02x." + \
             "%02x%02x%02x%02x.%02x%02x%02x%02x.%08x.%04x%04x"
             
        return MobID(f % tuple(mobid_list))
    
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