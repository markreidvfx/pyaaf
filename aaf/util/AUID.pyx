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