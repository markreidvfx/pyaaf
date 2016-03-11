cdef fused format_specifier:
    lib.aafInt8
    lib.aafInt16
    lib.aafInt32
    lib.aafUInt32
    lib.aafColorSpace_t
    lib.aafRect_t
    lib.aafFrameLayout_t
    lib.aafColorSiting_t
    lib.aafUID_t
    lib.aafBoolean_t
    lib.aafRational_t


cdef class EssenceFormat(AAFBase):
    def __cinit__(self):
        self.iid = lib.IID_IAAFEssenceFormat
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFEssenceFormat)

        AAFBase.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    def __setitem__(self, x, y):
        self.set_format_specifier(x,y)

    def __getitem__(self, x):
        for i in xrange(self.count()):
            name = self.get_format_specifier_name(i)
            if name.lower() == x.lower():
                return self.get_format_specifier_value(i)
        raise KeyError(x)

    def keys(self):
        keys = []
        for i in xrange(self.count()):
            keys.append(self.get_format_specifier_name(i))
        return keys

    def has_key(self, x):
        if x.lower() in self.keys():
            return True
        return False

    def all_keys(self):
        return [name for name, item in EssenceFormatDefMap.items()]

    def to_dict(self):
        d = {}
        for i in xrange(self.count()):
            name = self.get_format_specifier_name(i)
            value = self.get_format_specifier_value(i)
            d[name] = value

        return d

    def __repr__(self):
        return str(self.to_dict())

    def count(self):
        cdef lib.aafInt32 count
        error_check(self.ptr.NumFormatSpecifiers(&count))
        return count

    def get_format_specifier_auid(self, lib.aafInt32 index):
        if index >= self.count() or index < 0:
            raise IndexError("invalid index %i" % index)

        cdef AUID auid = AUID()

        error_check(self.ptr.GetIndexedFormatSpecifier(index, &auid.auid, 0, NULL, NULL))
        return auid

    def get_format_specifier_type(self, lib.aafInt32 index):

        specifier_auid = self .get_format_specifier_auid(index)
        for name, item in EssenceFormatDefMap.items():
            if specifier_auid == item[0]:
                return item[1]

        raise ValueError("unknown format specifier auid: %s" %(str(specifier_auid)))

    def get_format_specifier_name(self, lib.aafInt32 index):
        specifier_auid = self .get_format_specifier_auid(index)
        for name, item in EssenceFormatDefMap.items():
            if specifier_auid == item[0]:
                return name

        raise ValueError("unknown format specifier auid: %s" %(str(specifier_auid)))

    def get_format_specifier_value(self, lib.aafInt32 index):
        specifier_type = self.get_format_specifier_type(index)
        specifier_name = self.get_format_specifier_name(index)

        cdef lib.aafInt32 bytes_read

        cdef lib.aafInt8 value_Int8
        cdef lib.aafInt16 value_Int16
        cdef lib.aafInt32 value_Int32
        cdef lib.aafUInt32 value_UInt32
        cdef lib.aafColorSpace_t value_ColorSpace
        cdef lib.aafRect_t  value_Rect
        cdef lib.aafFrameLayout_t value_FrameLayout
        cdef lib.aafColorSiting_t value_ColorSiting
        cdef lib.aafUID_t value_UID
        cdef lib.aafBoolean_t value_bool

        cdef lib.aafRational_t value_rational

        cdef AUID auid = AUID()

        if specifier_type == 'operand.expInt32':
            error_check(self.ptr.GetIndexedFormatSpecifier(index, &auid.auid, sizeof(lib.aafInt32), <lib.aafUInt8*> &value_Int32, &bytes_read))
            return value_Int32

        elif specifier_type  == 'operand.expUInt32':

            error_check(self.ptr.GetIndexedFormatSpecifier(index, &auid.auid, sizeof(lib.aafUInt32), <lib.aafUInt8*> &value_UInt32, &bytes_read))
            return value_UInt32

        elif specifier_type == 'operand.expRational':
            error_check(self.ptr.GetIndexedFormatSpecifier(index, &auid.auid, sizeof(lib.aafRational_t), <lib.aafUInt8*> &value_rational, &bytes_read))
            return aafRational_to_fraction(value_rational)

        else:
            raise NotImplementedError("get_format_specifier_value not implemented for: %s" % specifier_type)

    def set_format_specifier(self, specifier, object value ):

        specifier = specifier.lower()
        cdef AUID auid_obj = EssenceFormatDefMap[specifier][0]
        cdef AUID audi_operand_obj
        cdef lib.aafUID_t auid = auid_obj.get_auid()

        specifier_type = EssenceFormatDefMap[specifier][1]

        cdef lib.aafRect_t rect
        cdef lib.aafInt32 line_map[5]
        cdef lib.aafRational_t value_rational

        #print auid_obj.auid,specifier_type

        if specifier_type == 'operand.expInt32':
            set_format_specifier[lib.aafInt32](self,auid, value)
        elif specifier_type in ('operand.expUInt32', '?operand.expUInt32'):
            set_format_specifier[lib.aafUInt32](self,auid, value)
        elif specifier_type == 'operand.expBoolean':
            set_format_specifier[lib.aafBoolean_t](self,auid, value)
        elif specifier_type == 'operand.expPixelFormat':
            set_format_specifier[lib.aafColorSpace_t](self, auid, ColorSpace[value.lower()])
        elif specifier_type == 'operand.expRect':
            rect.xSize = value[0]
            rect.ySize = value[1]
            rect.xOffset = value[2]
            rect.yOffset = value[3]
            set_format_specifier[lib.aafRect_t](self,auid, rect)
        elif specifier_type == 'operand.expRational':
            fraction_to_aafRational(value, value_rational)
            set_format_specifier[lib.aafRational_t](self,auid, value_rational)
        elif specifier_type == 'operand.expFrameLayout':
            set_format_specifier[lib.aafFrameLayout_t](self,auid, FrameLayout[value.lower()])
        elif specifier_type == 'operand.expColorSiting':
            set_format_specifier[lib.aafColorSiting_t](self,auid, ColorSiting[value.lower()])
        elif specifier_type == "operand.expAuid":
            audi_operand_obj = CompressionDefMap[value.lower()]
            set_format_specifier[lib.aafUID_t](self, auid, audi_operand_obj.get_auid())
        elif specifier_type == "operand.expLineMap":
            length = len(value)
            for i,value in enumerate(value):
                line_map[i] = value
            error_check(self.ptr.AddFormatSpecifier(auid, sizeof(lib.aafInt32)*length, <lib.aafUInt8*> &line_map))
        else:
            raise NotImplementedError(specifier_type)

cdef object set_format_specifier(EssenceFormat format,lib.aafUID_t &auid, format_specifier value):
    error_check(format.ptr.AddFormatSpecifier(auid, sizeof(format_specifier), <lib.aafUInt8*> &value))
