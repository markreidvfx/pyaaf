
cdef class EssenceData(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFEssenceData
        self.auid = lib.AUID_AAFEssenceData
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFEssenceData)

        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, SourceMob source_mob not None):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        error_check(self.ptr.Initialize(source_mob.src_ptr))


    def read(self, bytes_to_read = None):
        cdef lib.aafInt32 readsize

        if bytes_to_read is None:
            readsize = self.size - self.position
        else:
            readsize = min(bytes_to_read, self.size - self.position)

        if readsize <= 0:
            return None

        buf = bytearray(readsize)
        cdef unsigned char[:] data = buf
        cdef lib.aafUInt32 bytes_read = 0

        cdef lib.HRESULT ret
        with nogil:
            ret = self.ptr.Read(readsize,
                                <lib.aafUInt8 *> &data[0],
                                &bytes_read)
        error_check(ret)
        if bytes_read < readsize:
            return buf[:bytes_read]

        return buf

    def readinto(self, unsigned char[:] data not None):
        cdef lib.aafUInt32 readsize = len(data)
        cdef lib.aafUInt32 bytes_read = 0

        cdef lib.aafUInt32 bytes_left = self.size - self.position
        if bytes_left <= 0 or readsize == 0:
            return 0

        cdef lib.HRESULT ret
        with nogil:
            ret = self.ptr.Read(readsize,
                                <lib.aafUInt8 *> &data[0],
                                &bytes_read)
        error_check(ret)
        return bytes_read

    def write(self, unsigned char[:] data not None):
        cdef lib.aafUInt32 bytes_written
        cdef lib.HRESULT ret
        cdef lib.aafUInt32 data_size = len(data)
        with nogil:
            ret = self.ptr.Write(data_size,
                                 <lib.aafUInt8 *> &data[0],
                                 &bytes_written)
        error_check(ret)
        return bytes_written

    property position:
        def __get__(self):
            cdef lib.aafPosition_t value
            error_check(self.ptr.GetPosition(&value))
            return value
        def __set__(self, lib.aafPosition_t  value):
            error_check(self.ptr.SetPosition(value))

    property size:
        def __get__(self):
            cdef lib.aafLength_t value
            error_check(self.ptr.GetSize(&value))
            return value
    property source_mob:
        def __get__(self):
            cdef SourceMob mob = SourceMob.__new__(SourceMob)
            error_check(self.ptr.GetFileMob(&mob.src_ptr))
            mob.query_interface()
            mob.root = self.root
            return mob
        def __set__(self, SourceMob mob):
            error_check(self.ptr.SetFileMob(mob.src_ptr))
