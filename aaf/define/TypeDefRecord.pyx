cdef class TypeDefRecord(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefRecord
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefRecord)
            
        TypeDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def size(self):
        cdef lib.aafUInt32 count
        error_check(self.ptr.GetCount(&count))
        return count
    
    def keys(self):
        keys = []
        for i in xrange(self.size()):
            keys.append(self.member_name(i))
        
        return keys
    
    def typedef_dict(self):
        d = {}
        for i in xrange(self.size()): 
            d[self.member_name(i)] = self.member_typedef(i)
        return d
    
    def value_dict(self, PropertyValue p_value):
        d = {}
        for i in xrange(self.size()): 
            d[self.member_name(i)] = self.member_value(p_value, i)
        return d
    
    def member_name(self, lib.aafUInt32 index):
        cdef lib.aafUInt32 sizeInChars
        cdef lib.aafUInt32 sizeInBytes
        
        error_check(self.ptr.GetMemberNameBufLen(index, &sizeInBytes))
        sizeInChars = sizeInBytes / sizeof(lib.aafCharacter) + 1
        
        cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
        
        error_check(self.ptr.GetMemberName(index,
                                           &buf[0],
                                           sizeInBytes))
        
        cdef wstring value = wstring(&buf[0])
        return wideToString(value)
    
    def member_type(self, lib.aafUInt32 index):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)
        
        error_check(self.ptr.GetMemberType(index, &typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(typedef)
        
    
    def member_value(self, PropertyValue p_value, lib.aafUInt32 index):
        cdef PropertyValue member_value = PropertyValue.__new__(PropertyValue)
        
        error_check(self.ptr.GetValue(p_value.ptr,
                                       index,
                                       &member_value.ptr
                                       ))
        member_value.query_interface()
        member_value.root = self.root
        return member_value
    
    def set_value_from_dict(self, PropertyValue p_value, dict value):
        
        value_dict = self.value_dict(p_value)
        for key, item in value.items():
            if not value_dict.has_key(key):
                raise ValueError("TypeDefRecord does not have key %s" % key)
            
        cdef PropertyValue member_value
        
        keys = self.keys()
        
        cdef lib.aafUInt32 index
        for key, item in value.items():
            member_value = value_dict[key] 
            member_value.value = item
            index = keys.index(key)
            error_check(self.ptr.SetValue(p_value.ptr, index, member_value.ptr))
    
    def set_value_from_list(self, PropertyValue p_value, object value):
        
        value_dict = {}
        
        for i,item in enumerate((value)):
            value_dict[self.member_name(i)] = item
        
        self.set_value_from_dict(p_value, value_dict)
    
    def set_value(self, PropertyValue p_value, value):
        
        if isinstance(value, dict):
            self.set_value_from_dict(p_value, value)
            return
        if isinstance(value, (list, tuple)):
            self.set_value_from_list(p_value, value)
            return
        
        
        cdef AUID auid_typdef = AUID()
        
        auid_typdef.from_auid(lib.kAAFTypeID_Rational)
        
        if self.auid == auid_typdef:
            frac = AAFFraction(value).limit_denominator(200000000)
            self.set_value_from_dict(p_value, {'Numerator':frac.numerator, 'Denominator': frac.denominator})
            return

        raise NotImplementedError("setting record for for format not supported yet")
    
    def value(self, PropertyValue p_value):
        value_dict = {}
        
        cdef AUID auid_typdef = AUID()
        auid_typdef.from_auid(lib.kAAFTypeID_AUID)
        
        if self.auid == auid_typdef:
            return auid_from_prop_value(self, p_value)
        
        auid_typdef.from_auid(lib.kAAFTypeID_MobIDType)
        
        if self.auid == auid_typdef:
            return mobid_from_prop_value(self, p_value)
        
        auid_typdef.from_auid(lib.kAAFTypeID_DateStruct)
        
        if self.auid == auid_typdef:
            return get_date(self, p_value)
        
        auid_typdef.from_auid(lib.kAAFTypeID_TimeStruct)
        
        if self.auid == auid_typdef:
            return get_time(self, p_value)
        
        auid_typdef.from_auid(lib.kAAFTypeID_TimeStamp)
        
        if self.auid == auid_typdef:
            return get_timestamp(self, p_value)
        
        auid_typdef.from_auid(lib.kAAFTypeID_Rational)
        
        if self.auid == auid_typdef:
            try:
                return AAFFraction(self.member_value(p_value, 0).value, self.member_value(p_value, 1).value)
            except:
                pass

        for i in xrange(self.size()):
            value_prop = self.member_value(p_value, i)
            value_type = self.member_type(i)
            value_dict[self.member_name(i)] = resolve_typedef(value_type).value(value_prop)
        
        return value_dict
            
cdef object auid_from_prop_value(TypeDefRecord record, PropertyValue value ):
    cdef AUID retAUID = AUID()
    cdef lib.aafUID_t auid
    
    auid.Data1 = record.member_value(value, 0).value
    auid.Data2 = record.member_value(value, 1).value
    auid.Data3 = record.member_value(value, 2).value
    for i,v in  enumerate(record.member_value(value, 3).value):
        auid.Data4[i] = v
    retAUID.auid = auid
    return retAUID

cdef object mobid_from_prop_value(TypeDefRecord record, PropertyValue value):
    cdef MobID mobID_obj = MobID()

    cdef lib.aafMobID_t mobID_t
    
    for i,v in enumerate(record.member_value(value, 0).value):
        mobID_t.SMPTELabel[i] = v
    
    mobID_t.length = record.member_value(value, 1).value
    mobID_t.instanceHigh = record.member_value(value, 2).value
    mobID_t.instanceMid = record.member_value(value, 3).value
    mobID_t.instanceLow = record.member_value(value, 4).value
    
    cdef AUID auid = record.member_value(value, 5).value
    
    mobID_t.material = auid.auid
    
    mobID_obj.mobID = mobID_t
    return mobID_obj
    

cdef object get_time(TypeDefRecord record, PropertyValue value):
    hour = record.member_value(value, 0).value
    minute = record.member_value(value, 1).value
    second = record.member_value(value,2).value
    fraction = record.member_value(value,3).value
    
    return "%02d:%02d:%02d.%02d" % (hour, minute, second, fraction)

cdef object get_date(TypeDefRecord record, PropertyValue value):
    
    year = record.member_value(value, 0).value
    month = record.member_value(value, 1).value
    day = record.member_value(value,2).value
    
    return "%d-%02d-%02d" % (year, month, day)

cdef object get_timestamp(TypeDefRecord record, PropertyValue value):
    
    return "%s %s" % ( record.member_value(value, 0).value, record.member_value(value, 1).value)