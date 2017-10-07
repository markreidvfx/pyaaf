from libc.stdio cimport sscanf

cdef class MobID(object):

    def __init__(self, mobID = None):
        if not mobID:
            return
        if isinstance(mobID, dict):
            self._from_dict(mobID)
        elif isinstance(mobID, (tuple, list)):
            self._from_list(mobID)
        else:
            self.urn = mobID

    cdef object _from_str(self, object mob_id):
        self.urn = mob_id
        return

    cdef object _from_list(self, object id_list):
        f = "urn:smpte:umid:%02x%02x%02x%02x.%02x%02x%02x%02x.%02x%02x%02x%02x." + \
             "%02x"  + \
             "%02x%02x%02x." + \
             "%02x%02x%02x%02x.%02x%02x%02x%02x.%02x%02x%02x%02x.%02x%02x%02x%02x"
        if len(id_list) != 32:
            raise ValueError("Invalid length expected 32 got %d"  % len(id_list))
        self.urn = f % tuple(id_list)

    cdef object _from_dict(self, dict d):
        self.mobID.length = d.get("length", 0)
        self.mobID.instanceHigh = d.get("instanceHigh", 0)
        self.mobID.instanceMid = d.get("instanceMid", 0)
        self.mobID.instanceLow = d.get("instanceLow", 0)

        material = d.get("material", {'Data1':0, 'Data2':0, 'Data3':0})

        self.mobID.material.Data1 = material.get('Data1', 0)
        self.mobID.material.Data2 = material.get('Data2', 0)
        self.mobID.material.Data3 = material.get('Data3', 0)

        Data4 = material.get("Data4", [0 for i in xrange(8)])

        for i in xrange(8):
            if i >= len(Data4):
                break
            self.mobID.material.Data4[i] = Data4[i]

        SMPTELabel = d.get("SMPTELabel", [0 for i in xrange(12)])
        for i in xrange(12):
            if i >= len(SMPTELabel):
                break
            self.mobID.SMPTELabel[i] = SMPTELabel[i]


    cdef lib.aafMobID_t get_aafMobID_t(self):
        return self.mobID

    @staticmethod
    def new():
        cdef MobID m = MobID()
        m.mobID.SMPTELabel = [0x06, 0x0a, 0x2b, 0x34, 0x01, 0x01, 0x01, 0x05, 0x01, 0x01, 0x0f, 0x00]
        m.mobID.length = 0x13
        m.mobID.instanceHigh = 0x00
        m.mobID.instanceMid = 0x00
        m.mobID.instanceLow = 0x00
        import uuid
        m.material = uuid.uuid4()
        return m

    @staticmethod
    def from_dict(dict d):
        return MobID(d)

    @staticmethod
    def from_list(mobid_list):
        return MobID(mobid_list)

    def to_list(self):
        umid = self.urn
        for item in ("urn:smpte:umid:",'.' ):
            umid = umid.replace(item, '')
        return [int(umid[i:i+2], 16) for i in range(0, len(umid), 2)]

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

    def __richcmp__(x, y, int op):
        if op == 2 or 3:
            result = False
            if str(MobID(x)) == str(MobID(y)):
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
        return self.urn

    property urn:
        def __get__(self):
            mobID = self.mobID
            # handle case UMIDs where the material number is half swapped
            if mobID.SMPTELabel[11] == 0x00 and \
               mobID.material.Data4[0] == 0x06 and \
               mobID.material.Data4[1] == 0x0E and \
               mobID.material.Data4[2] == 0x2B and \
               mobID.material.Data4[3] == 0x34 and \
               mobID.material.Data4[4] == 0x7F and \
               mobID.material.Data4[5] == 0x7F:

                f = "urn:smpte:umid:%02x%02x%02x%02x.%02x%02x%02x%02x.%02x%02x%02x%02x." + \
                 "%02x"  + \
                 "%02x%02x%02x." + \
                 "%02x%02x%02x%02x.%02x%02x%02x%02x.%08x.%04x%04x"

                return f % (
                     mobID.SMPTELabel[0], mobID.SMPTELabel[1], mobID.SMPTELabel[2],  mobID.SMPTELabel[3],
                     mobID.SMPTELabel[4], mobID.SMPTELabel[5], mobID.SMPTELabel[6],  mobID.SMPTELabel[7],
                     mobID.SMPTELabel[8], mobID.SMPTELabel[9], mobID.SMPTELabel[10], mobID.SMPTELabel[11],
                     mobID.length,
                     mobID.instanceHigh, mobID.instanceMid, mobID.instanceLow,
                     mobID.material.Data4[0], mobID.material.Data4[1], mobID.material.Data4[2], mobID.material.Data4[3],
                     mobID.material.Data4[4], mobID.material.Data4[5], mobID.material.Data4[6], mobID.material.Data4[7],
                     mobID.material.Data1, mobID.material.Data2, mobID.material.Data3)
            else:
                f = "urn:smpte:umid:%02x%02x%02x%02x.%02x%02x%02x%02x.%02x%02x%02x%02x." + \
                 "%02x"  + \
                 "%02x%02x%02x." + \
                 "%08x.%04x%04x.%02x%02x%02x%02x.%02x%02x%02x%02x"

                return f % (
                     mobID.SMPTELabel[0], mobID.SMPTELabel[1], mobID.SMPTELabel[2],  mobID.SMPTELabel[3],
                     mobID.SMPTELabel[4], mobID.SMPTELabel[5], mobID.SMPTELabel[6],  mobID.SMPTELabel[7],
                     mobID.SMPTELabel[8], mobID.SMPTELabel[9], mobID.SMPTELabel[10], mobID.SMPTELabel[11],
                     mobID.length,
                     mobID.instanceHigh, mobID.instanceMid, mobID.instanceLow,
                     mobID.material.Data1, mobID.material.Data2, mobID.material.Data3,
                     mobID.material.Data4[0], mobID.material.Data4[1], mobID.material.Data4[2], mobID.material.Data4[3],
                     mobID.material.Data4[4], mobID.material.Data4[5], mobID.material.Data4[6], mobID.material.Data4[7])

        def __set__(self, value):
            cdef unsigned int data[32]
            cdef int ret

            s = str(value)
            for item in ("urn:smpte:umid:", ".", '-', '0x'):
                s = s.replace(item, '')
            s = s.lower()
            if isinstance(s, unicode):
                s = s.encode("ascii")

            ret = sscanf(s, "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
                            "%02x"
                            "%02x%02x%02x"
                            "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                            &data[0], &data[1], &data[2], &data[3],
                            &data[4], &data[5], &data[6], &data[7],
                            &data[8], &data[9], &data[10], &data[11],
                            &data[12],
                            &data[13], &data[14], &data[15],
                            &data[16], &data[17], &data[18], &data[19],
                            &data[20], &data[21],
                            &data[22], &data[23],
                            &data[24], &data[25], &data[26], &data[27],
                            &data[28], &data[29], &data[30], &data[31])

            if ret != 32:
                raise ValueError("Invalid MobId")

            for i in range(12):
                self.mobID.SMPTELabel[i] = data[i]

            self.mobID.length = data[12]
            self.mobID.instanceHigh = data[13]
            self.mobID.instanceMid = data[14]
            self.mobID.instanceLow = data[15]

            # handle case UMIDs where the material number is half swapped
            if data[11] == 0x00 and \
                data[16] == 0x06 and data[17] == 0x0E and data[18] == 0x2B and \
                data[19] == 0x34 and data[20] == 0x7F and data[21] == 0x7F:

                self.mobID.material.Data1 = (data[24] << 24) + (data[25] << 16) + (data[26] << 8) + data[27]
                self.mobID.material.Data2 = (data[28] << 8) + data[29]
                self.mobID.material.Data3 = (data[30] << 8) + data[31]
                for i in range(8):
                     self.mobID.material.Data4[i] = data[i + 16]
            else:
                self.mobID.material.Data1 = (data[16] << 24) + (data[17] << 16) + (data[18] << 8) + data[19]
                self.mobID.material.Data2 = (data[20] << 8) + data[21]
                self.mobID.material.Data3 = (data[22] << 8) + data[23]
                for i in range(8):
                    self.mobID.material.Data4[i] = data[i + 24]

    property umid:

        def __get__(self):
            f = "0x%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X" + \
                "%02X"  + \
                "%02X%02X%02X" + \
                "%08X%04X%04X" + \
                "%02X%02X%02X%02X%02X%02X%02X%02X"

            mobID = self.mobID
            return f % (
                 mobID.SMPTELabel[0], mobID.SMPTELabel[1], mobID.SMPTELabel[2],  mobID.SMPTELabel[3],
                 mobID.SMPTELabel[4], mobID.SMPTELabel[5], mobID.SMPTELabel[6],  mobID.SMPTELabel[7],
                 mobID.SMPTELabel[8], mobID.SMPTELabel[9], mobID.SMPTELabel[10], mobID.SMPTELabel[11],
                 mobID.length,
                 mobID.instanceHigh, mobID.instanceMid, mobID.instanceLow,
                 mobID.material.Data1, mobID.material.Data2, mobID.material.Data3,
                 mobID.material.Data4[0], mobID.material.Data4[1], mobID.material.Data4[2], mobID.material.Data4[3],
                 mobID.material.Data4[4], mobID.material.Data4[5], mobID.material.Data4[6], mobID.material.Data4[7])

        def __set__(self, value):
            self.urn = value

    property material:

        def __get__(self):
            cdef AUID auid = AUID()
            auid.auid = self.mobID.material
            return auid
        def __set__(self, value):
            cdef AUID auid = AUID(value)
            self.mobID.material = auid.auid

    def __int__(self):
        return self.int

    property int:

        def __get__(self):
            cdef lib.aafUInt8 *p = <lib.aafUInt8*> &self.mobID
            num = 0
            for i in range(32):
                num += p[31-i] << (i * 8)
            return num

        def __set__(self, value):

            cdef lib.aafUInt8 *p = <lib.aafUInt8*> &self.mobID
            for i in range(32):
                p[31-i] = (value >> i*8) & 0xff
