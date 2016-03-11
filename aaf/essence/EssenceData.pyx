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


    def read(self, lib.aafUInt32  bytes):

        cdef lib.aafUInt32 readsize = min(bytes, self.size - self.position)

        if readsize <= 0:
            return None

        cdef vector[lib.UChar] buf = vector[lib.UChar](readsize)
        cdef lib.aafUInt32 bytes_read = 0

        error_check(self.ptr.Read(readsize,
                                  <lib.aafUInt8 *> &buf[0],
                                  &bytes_read))

        cdef string s = string(<char *> &buf[0], bytes_read )
        return s

    def write(self, bytes data):
        cdef string s_data = string(data)
        cdef lib.aafUInt32 bytes_written

        error_check(self.ptr.Write(len(data),
                                   <lib.aafUInt8 *> s_data.c_str(),
                                   &bytes_written
                                   ))

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
