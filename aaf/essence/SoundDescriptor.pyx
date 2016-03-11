cdef class SoundDescriptor(FileDescriptor):
    def __cinit__(self):
        self.iid = lib.IID_IAAFSoundDescriptor
        self.auid = lib.AUID_AAFSoundDescriptor
        self.snd_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.snd_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.snd_ptr, lib.IID_IAAFSoundDescriptor)

        FileDescriptor.query_interface(self, obj)

    def __dealloc__(self):
        if self.snd_ptr:
            self.snd_ptr.Release()
