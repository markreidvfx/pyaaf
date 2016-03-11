
from libc.stdlib cimport malloc, free

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

    def __init__(self, root, record_name_typedef_pairs, AUID auid not None, name not None):
        """
        Valid TypeDefs
        - TypeDefInt
        - TypeDefRecord
        - TypeDefEnum
        - TypeDefExtEnum
        - TypeDefFixedArray
        """
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_meta_instance(self, lib.AUID_AAFTypeDefRecord)


        cdef TypeDef typedef

        record_name_list = []
        typedef_list = []

        for item in record_name_typedef_pairs:
            if len(item) is not 2:
                raise ValueError("key_typedef_pairs must be pairs [ (element_name, [typedef_name or TypeDef]), ...] ")
            record_name = AAFCharBuffer(item[0])
            if isinstance(item[1], TypeDef):
                typedef = item[1]
            else:
                typedef = dictionary.lookup_typedef(item[1])

            if not isinstance(typedef, (TypeDefInt, TypeDefRecord, TypeDefEnum, TypeDefExtEnum, TypeDefFixedArray)):
                raise ValueError("Typedef can only be TypeDefInt, TypeDefRecord, TypeDefEnum, TypeDefExtEnum orTypeDefFixedArray")

            record_name_list.append(record_name)
            typedef_list.append(typedef)

        cdef AAFCharBuffer aafchar_buf

        cdef lib.IAAFTypeDef** typedef_array = <lib.IAAFTypeDef**> malloc(len(record_name_list) * sizeof(lib.IAAFTypeDef*))
        cdef lib.aafCharacter ** record_name_array = <lib.aafCharacter** >malloc(len(record_name_list) * sizeof(lib.aafCharacter*))
        try:

            for i, (record_name, typedef) in enumerate(zip(record_name_list, typedef_list )):
                typedef_array[i] = typedef.typedef_ptr

                aafchar_buf = record_name
                record_name_array[i] = aafchar_buf.get_ptr()

            aafchar_buf = AAFCharBuffer(name)

            error_check(self.ptr.Initialize(auid.get_auid(), typedef_array, record_name_array, len(record_name_list), aafchar_buf.get_ptr()))

        finally:
            free(typedef_array)
            free(record_name_array)

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

    def create_property_value(self, value):

        property_values = []

        cdef lib.aafUInt32 num_members = self.size()

        value_list = []
        if isinstance(value, dict):
            type_def_dict =self.typedef_dict()
            for key in self.keys():
                v = value[key]
                typdef = type_def_dict[key]
                property_values.append(typdef.create_property_value(v))

        else:
            for i,v in enumerate(value):
                typdef = self.member_typedef(i)
                property_values.append(typdef.create_property_value(v))

        if len(property_values) != num_members:
            raise ValueError("not enough values")

        cdef PropertyValue working_value
        cdef PropertyValue out_value = PropertyValue.__new__(PropertyValue)

        cdef lib.IAAFPropertyValue ** member_values = <lib.IAAFPropertyValue **> malloc(num_members * sizeof(lib.IAAFPropertyValue*))
        if not member_values:
            raise MemoryError()

        try:
            for i,working_value in enumerate(property_values):
                member_values[i] = working_value.ptr

            error_check(self.ptr.CreateValueFromValues(member_values, num_members, &out_value.ptr))
            out_value.query_interface()
            out_value.root = self.root
            return out_value


        finally:
            free(member_values)
        #cdef lib.IAAFTypeDef** typedef_array = <lib.IAAFTypeDef**> malloc(len(record_name_list) * sizeof(lib.IAAFTypeDef*))
        #HRESULT CreateValueFromValues(IAAFPropertyValue ** pMemberValues, aafUInt32  numMembers, IAAFPropertyValue ** ppPropVal)

    def member_name(self, lib.aafUInt32 index):
        cdef lib.aafUInt32 size_in_bytes
        error_check(self.ptr.GetMemberNameBufLen(index, &size_in_bytes))

        cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)
        buf.size_in_bytes = size_in_bytes
        error_check(self.ptr.GetMemberName(index, buf.get_ptr(), buf.size_in_bytes))

        return buf.read_str()

    def member_typedef(self, lib.aafUInt32 index):
        cdef TypeDef typedef = TypeDef.__new__(TypeDef)

        error_check(self.ptr.GetMemberType(index, &typedef.typedef_ptr))
        typedef.query_interface()
        typedef.root = self.root
        return resolve_typedef(typedef)

    def member_create_property_value(self, lib.aafUInt32 index, value):
        typdef = self.member_typedef(index)
        return typdef.create_property_value(value)

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

        keys = self.keys()

        for key, item in value.items():
            if key not in keys:
                raise ValueError("TypeDefRecord does not have key %s" % key)

        value_list = []

        for key in self.keys():
            value_list.append(value[key])

        if len(value_list) != self.size():
            raise ValueError("Not enough values expected %i items got %i" % (self.size(), len(value_list)))

        return self.create_property_value(value_list)


    def set_value_from_list(self, PropertyValue p_value, object value):

        value_dict = {}

        for i,item in enumerate((value)):
            value_dict[self.member_name(i)] = item

        self.set_value_from_dict(p_value, value_dict)

    def set_value(self, PropertyValue p_value, value):
        cdef AUID auid_typdef = AUID()

        if isinstance(value, dict):
            return self.set_value_from_dict(p_value, value)

        auid_typdef.from_auid(lib.kAAFTypeID_MobIDType)
        if isinstance(value, (list, tuple)) and self.auid != auid_typdef:
            return self.set_value_from_list(p_value, value)

        if self.auid == auid_typdef:
            return self.set_value_from_dict(p_value, MobID(value).to_dict())

        auid_typdef.from_auid(lib.kAAFTypeID_Rational)
        if self.auid == auid_typdef:
            frac = AAFFraction(value).limit_denominator(200000000)
            return self.set_value_from_dict(p_value, {'Numerator':frac.numerator, 'Denominator': frac.denominator})

        auid_typdef.from_auid(lib.kAAFTypeID_AUID)
        if self.auid == auid_typdef:
            return self.set_value_from_dict(p_value, AUID(value).to_auid_dict())

        raise ValueError("setting record by %s not supported" % str(type(value)))

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
            value_type = self.member_typedef(i)
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
