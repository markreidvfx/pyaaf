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
    
    def to_dict(self):
        
        material = {'Data1': self.mobID.material.Data1,
                    'Data2': self.mobID.material.Data2,
                    'Data3': self.mobID.material.Data3,
                    'Data4': [self.mobID.material.Data4[i] for i in xrange(8)]
                    }
        SMPTELabel = [self.mobID.SMPTELabel[i] for i in xrange(12)]
        
        return {'material':material, 
                'length': self.mobID.length,
                'instanceHigh': self.mobID.instanceHigh,
                'instanceMid': self.mobID.instanceMid,
                'instanceLow': self.mobID.instanceLow,
                'SMPTELabel': SMPTELabel
                }
    @staticmethod
    def from_dict(dict d):
        m = MobID()
        
        m.mobID.length = d.get("length", 0)
        m.mobID.instanceHigh = d.get("instanceHigh", 0)
        m.mobID.instanceMid = d.get("instanceMid", 0)
        m.mobID.instanceLow = d.get("instanceLow", 0)
        
        material = d.get("material", {'Data1':0, 'Data2':0, 'Data3':0})
        
        m.mobID.material.Data1 = material.get('Data1', 0)
        m.mobID.material.Data2 = material.get('Data2', 0)
        m.mobID.material.Data3 = material.get('Data3', 0)
        
        Data4 = material.get("Data4", [0 for i in xrange(8)])
        
        for i in xrange(8):
            if i >= len(Data4):
                break
            m.mobID.material.Data4[i] = Data4[i]
            
        SMPTELabel = d.get("SMPTELabel", [0 for i in xrange(12)])
        for i in xrange(12):
            if i >= len(SMPTELabel):
                break
            m.mobID.SMPTELabel[i] = SMPTELabel[i]
        return m
    
    @staticmethod
    def from_list(mobid_list):
        f = "urn:smpte:umid:%02x%02x%02x%02x.%02x%02x%02x%02x.%02x%02x%02x%02x." + \
             "%02x"  + \
             "%02x%02x%02x." + \
             "%02x%02x%02x%02x.%02x%02x%02x%02x.%08x.%04x%04x"
             
        return MobID(f % tuple(mobid_list))
    
    def __richcmp__(x, y, int op):
        if op == 2 or 3:
            result = False
            if str(x) == str(y):
                result = True
            if op == 3:
                return not result
            return result
        
        raise NotImplemented("richcmp %d not not Implemented" % op)
        
    
    def __repr__(self):
        return '<%s.%s of %s at 0x%x>' % (
            self.__class__.__module__,
            self.__class__.__name__,
            str(self),
            id(self),
        )

    def __str__(self):
        
        f = "urn:smpte:umid:%02x%02x%02x%02x.%02x%02x%02x%02x.%02x%02x%02x%02x." + \
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