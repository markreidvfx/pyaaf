cdef class Timecode(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTimecode
        self.auid = lib.AUID_AAFTimecode
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTimecode)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, lib.aafLength_t length, lib.aafFrameOffset_t start_frame,
                   lib.aafUInt16 fps, drop = False):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        cdef lib.aafTimecode_t timecode
        timecode.startFrame = start_frame
        if drop:
            timecode.drop = lib.kAAFTcDrop
        else:
            timecode.drop = lib.kAAFTcNonDrop
        timecode.fps = fps

        error_check(self.ptr.Initialize(length, &timecode))
